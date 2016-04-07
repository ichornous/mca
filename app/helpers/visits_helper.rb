require 'securerandom'

module VisitsHelper
  class ActionView::Helpers::FormBuilder
    include ActionView::Context
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::JavaScriptHelper
    include ERB::Util

    def link_to_add_form(display_name, method, options = {}, &block)
      key_id = SecureRandom.hex

      new_object = @object.class.reflect_on_association(method).klass.new
      fields = fields_for(method, new_object, :child_index => key_id) do |builder|
        capture(builder, &block)
      end

      options ||= {}

      options.merge!('data-content' => "#{fields}")
      options.merge!('data-id-key' => key_id)
      link_to display_name, '#', options
    end

    def link_to_remove_form(name, options = {})
      hidden_field(:_destroy) + link_to(name, '#', options)
    end
  end
end
