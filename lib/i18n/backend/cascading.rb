require 'i18n'

module I18n
  module Backend
    class Cascading < Simple
      def translate(locale, key, options={})
        unless options[:cascade] == false
          options[:default] = Array(options[:default]) + decascade(locale, key, options[:scope], options[:separator])
          options[:cascade] = false # oh hai, recursion, kthxbai!
        end
        super
      end

      private
      def decascade(locale, key, scope=[], separator=nil)
        return unless key
        separator ||= '.'
        args = [locale, key, scope]
        args << separator if I18n.method(:normalize_translation_keys).arity == 4 # new version has additional separator parameter
        namespaces = I18n.send(:normalize_translation_keys, *args)[1..-1].collect { |k| k.to_s } # leave off the locale
        namespaces.reverse.inject([]) do |cascades, key|
          cascades << ((namespaces[0, namespaces.index(key)] << namespaces.last).join(separator)).to_sym
        end
      end
    end
  end
end