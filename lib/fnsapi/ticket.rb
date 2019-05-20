# frozen_string_literal: true

module Fnsapi
  class FieldValidationError < StandardError; end

  class Ticket
    attr_reader :fn, :fd, :pfd, :purchase_date, :amount_cents

    def initialize(object)
      %i[fn fd pfd].each do |field_name|
        instance_variable_set("@#{field_name}", validated_field_value(object, field_name, [String]))
      end

      @purchase_date = validated_field_value(object, :purchase_date, [String, Time, DateTime])
      @purchase_date = DateTime.parse(@purchase_date) if @purchase_date.is_a?(String)

      @amount_cents = validated_field_value(object, :amount_cents, [Integer])
    end


    private

    def validated_field_value(object, field, types)
      value = if object.is_a?(Hash)
                object[field] || object[field.to_s]
              else
                object.public_send(field)
              end

      raise FieldValidationError, "#{field} should be a type of #{types.join(', or ')}" unless types.member?(value.class)

      value
    end
  end
end
