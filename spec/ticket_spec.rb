# frozen_string_literal: true

RSpec.describe Fnsapi::Ticket do
  let(:purchase_date) { DateTime.now }
  let(:ticket) do
    OpenStruct.new(
      fn: '123',
      fd: '456',
      pfd: '789',
      purchase_date: purchase_date,
      amount_cents: 100_500
    )
  end
  let(:ticket_hash) do
    {
      fn: ticket.fn,
      'fd' => ticket.fd,
      'pfd' => ticket.pfd,
      purchase_date: ticket.purchase_date,
      'amount_cents' => ticket.amount_cents
    }
  end

  describe '#new' do
    context 'when object is an instance with methods' do
      let(:instance) { described_class.new(ticket) }

      it 'creates an instance of Ticket class' do
        expect(instance).to be_a(described_class)
      end

      it 'sets correct field values' do
        expect(instance.fn).to eq(ticket.fn)
        expect(instance.fd).to eq(ticket.fd)
        expect(instance.pfd).to eq(ticket.pfd)
        expect(instance.purchase_date).to eq(ticket.purchase_date)
        expect(instance.amount_cents).to eq(ticket.amount_cents)
      end

      context 'when date is a string' do
        before do
          ticket.purchase_date = ticket.purchase_date.strftime
        end

        it 'parses it to DateTime' do
          expect(ticket.purchase_date).to be_a(String)
          expect(instance.purchase_date).to be_a(DateTime)
          expect(instance.purchase_date).to eq(DateTime.parse(ticket.purchase_date))
        end
      end

      context 'when field has nil state' do
        before do
          ticket.purchase_date = nil
        end

        it 'raises an exception' do
          expect { described_class.new(ticket) }.to(
            raise_error(Fnsapi::FieldNotSpecifiedError, "purchase_date should be specified")
          )
        end
      end
    end

    context 'when object is a Hash' do
      let(:instance) { described_class.new(ticket_hash) }

      it 'creates an instance of Ticket class' do
        expect(instance).to be_a(described_class)
      end

      it 'sets correct field values' do
        expect(instance.fn).to eq(ticket_hash[:fn])
        expect(instance.fd).to eq(ticket_hash['fd'])
        expect(instance.pfd).to eq(ticket_hash['pfd'])
        expect(instance.purchase_date).to eq(ticket_hash[:purchase_date])
        expect(instance.amount_cents).to eq(ticket_hash['amount_cents'])
      end

      context 'when date is a string' do
        before do
          ticket[:purchase_date] = ticket[:purchase_date].strftime
        end

        it 'parses it to DateTime' do
          expect(ticket[:purchase_date]).to be_a(String)
          expect(instance.purchase_date).to be_a(DateTime)
          expect(instance.purchase_date).to eq(DateTime.parse(ticket[:purchase_date]))
        end
      end

      context 'when field has invalid type' do
        before do
          ticket[:purchase_date] = nil
        end

        it 'raises an exception' do
          expect { described_class.new(ticket) }.to(
            raise_error(Fnsapi::FieldNotSpecifiedError, "purchase_date should be specified")
          )
        end
      end
    end
  end
end
