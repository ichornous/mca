module ActionView
  module Helpers
    class FormBuilder
      def date_select(method, options = {}, html_options = {})
        existing_date = @object.send(method)
        formatted_date = existing_date.to_date.strftime("%F") if existing_date.present?
        unix_time = existing_time.to_time.to_i if existing_time.present?
        @template.content_tag(:div, :class => "input-group") do
          @template.text_field_tag("#{method}_view", formatted_date, class: "form-control datepicker", :"data-date-format" => "YYYY-MM-DD") +
              @template.content_tag(:span, @template.content_tag(:span, "", :class => "glyphicon glyphicon-calendar") ,:class => "input-group-addon") +
              hidden_field(method, :value => unix_time)
        end
      end

      def datetime_select(method, options = {}, html_options = {})
        existing_time = @object.send(method)
        formatted_time = existing_time.to_time.strftime("%F %I:%M %p") if existing_time.present?
        unix_time = existing_time.to_time.to_i if existing_time.present?
        @template.content_tag(:div, :class => "input-group") do
          @template.text_field_tag("#{method}_view", formatted_time, class: "form-control datetimepicker", :"data-date-format" => "YYYY-MM-DD hh:mm A") +
              @template.content_tag(:span, @template.content_tag(:span, "", :class => "glyphicon glyphicon-calendar") ,:class => "input-group-addon") +
              hidden_field(method, :value => unix_time)
        end
      end
    end
  end
end