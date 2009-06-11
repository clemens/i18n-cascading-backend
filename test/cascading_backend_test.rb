$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'i18n/backend/cascading'
# require File.dirname(__FILE__) + '/../lib/i18n/backend/cascading.rb'

# override default exception handler to always raise
module I18n
  class << self
    protected
    def default_exception_handler(exception, locale, key, options)
      raise exception
    end
  end
end

class CascadingBackendTest < Test::Unit::TestCase
  def setup
    I18n.backend = I18n::Backend::Cascading.new
    I18n.backend.store_translations :en, {
      :bat => 'bat',
      :outermost => {
        :bam => 'outermost bam',
        :outer => {
          :baz => 'outer baz',
          :inner => {
            :bar => 'inner bar',
            :innermost => {
              :foo => 'innermost foo'
            }
          }
        }
      }
    }
  end

  def test_translate_with_cascade
    assert_equal 'innermost foo', I18n.translate(:'outermost.outer.inner.innermost.foo')
    assert_equal 'inner bar', I18n.translate(:'outermost.outer.inner.innermost.bar')
    assert_equal 'outer baz', I18n.translate(:'outermost.outer.inner.innermost.baz')
    assert_equal 'outermost bam', I18n.translate(:'outermost.outer.inner.innermost.bam')
    assert_equal 'bat', I18n.translate(:'outermost.outer.inner.innermost.bat')
    assert_raise I18n::MissingTranslationData do
      I18n.translate(:'outermost.outer.inner.innermost.boom')
    end
  end

  def test_translate_with_cascade_and_defaults_prefers_defaults
    assert_equal 'bat', I18n.translate(:'outermost.outer.inner.innermost.bar', :default => :bat)
    assert_equal 'bat', I18n.translate(:'outermost.outer.inner.innermost.bar', :default => [:not_there, :bat])
    assert_equal 'inner bar', I18n.translate(:'outermost.outer.inner.innermost.bar', :default => [:not_there, :not_there_either])
    assert_raise I18n::MissingTranslationData do
      I18n.translate(:'outermost.outer.inner.innermost.boom', :default => [:not_there, :not_there_either])
    end
  end

  def test_translate_without_cascade
    assert_equal 'innermost foo', I18n.translate(:'outermost.outer.inner.innermost.foo', :cascade => false)
    # all others should raise
    [:bar, :baz, :bam, :boom].each do |key|
      assert_raise I18n::MissingTranslationData do
        I18n.translate(:"outermost.outer.inner.innermost.#{key}", :cascade => false)
      end
    end
  end
end