# frozen_string_literal: true

module Fnsapi
  class FieldNotSpecifiedError < StandardError; end

  class Ticket
    attr_reader :fn, :fd, :pfd, :purchase_date, :amount_cents

    def initialize(object)
      %i[fn fd pfd amount_cents].each do |field_name|
        instance_variable_set("@#{field_name}", validated_field_value(object, field_name))
      end

      @purchase_date = validated_field_value(object, :purchase_date)
      @purchase_date = DateTime.parse(@purchase_date) if @purchase_date.is_a?(String)
      true
    end


    private

    def validated_field_value(object, field)
      value = if object.is_a?(Hash)
                object[field] || object[field.to_s]
              else
                object.public_send(field)
              end

      raise FieldNotSpecifiedError, "#{field} should be specified" if value.blank?

      value
    end
  end
end
