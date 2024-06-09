# frozen_string_literal: true

module OutboxableTestHelpers
  extend RSpec::Matchers::DSL

  matcher :create_outbox_record do |outbox_class|
    match(notify_expectation_failures: true) do |actual|
      count = outbox_class.count
      expect { actual.call }.to change(outbox_class, :count).by_at_least(1)
      count = outbox_class.count - count

      if @attributes
        @attributes = @attributes.call if @attributes.is_a? Proc
        outboxes = outbox_class.last(count)
        expect(outboxes.map(&:attributes)).to match(array_including(hash_including(@attributes)))
      end

      true
    end

    match_when_negated(notify_expectation_failures: true) do |actual|
      expect { actual.call }.not_to change(outbox_class, :count)
    end

    supports_block_expectations
    diffable

    chain :with_attributes do |attributes|
      @attributes = attributes
    end
  end
end

RSpec.shared_context 'when using component specific Outbox model' do
  describe '#save' do
    subject { fake_model_instance.save }

    let(:fake_model_instance) { CustomOutbox::TestModel.new(identifier:) }
    let(:identifier) { SecureRandom.uuid }

    context 'when record is created' do
      context 'when outbox record is created' do
        it { is_expected.to be true }

        it 'creates the record' do
          expect { subject }.to change(CustomOutbox::TestModel, :count).by(1)
        end

        it 'creates the outbox record' do
          expect { subject }.to change(CustomOutbox::Outbox, :count).by(1)
        end

        it 'creates the outbox record with the correct data' do
          subject
          outbox = CustomOutbox::Outbox.last
          expect(outbox.aggregate).to eq('CustomOutbox::TestModel')
          expect(outbox.aggregate_identifier).to eq(identifier)
          expect(outbox.event).to eq('TEST_MODEL_CREATED.CUSTOM_OUTBOX')
          expect(outbox.identifier).not_to be_nil
          expect(outbox.payload['after'].to_json).to eq(CustomOutbox::TestModel.last.to_json)
          expect(outbox.payload['before']).to be_nil
        end
      end

      context 'when there is a record invalid error when creating the outbox record' do
        before do
          outbox = build(:transactional_outbox_outbox, event: nil)
          allow(CustomOutbox::Outbox).to receive(:new).and_return(outbox)
        end

        it { is_expected.to be false }

        it 'does not create the record' do
          expect { subject }.not_to change(CustomOutbox::TestModel, :count)
        end

        it 'does not create the outbox record' do
          expect { subject }.not_to change(CustomOutbox::Outbox, :count)
        end

        it 'adds the errors to the model' do
          expect { subject }.to change {
                                  fake_model_instance.errors.messages
                                }.from({}).to({ 'outbox.event': ["can't be blank"] })
        end
      end

      context 'when there is an error when creating the outbox record' do
        before do
          outbox = instance_double(CustomOutbox::Outbox, invalid?: false)
          allow(CustomOutbox::Outbox).to receive(:new).and_return(outbox)
          allow(outbox).to receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
        end

        it 'raises error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotSaved)
        end

        it 'does not create the record' do
          expect do
            subject
          end.to raise_error(ActiveRecord::RecordNotSaved).and not_change(CustomOutbox::TestModel, :count)
        end

        it 'does not create the outbox record' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotSaved).and not_change(CustomOutbox::Outbox, :count)
        end
      end
    end

    context 'when the record could not be created' do
      let(:identifier) { nil }

      it { is_expected.to be false }

      it 'does not create the record' do
        expect { subject }.not_to change(CustomOutbox::TestModel, :count)
      end

      it 'does not create the outbox record' do
        expect { subject }.not_to change(CustomOutbox::Outbox, :count)
      end
    end

    context 'when record is updated' do
      subject do
        fake_model_instance.identifier = new_identifier
        fake_model_instance.save
      end

      let(:fake_model_instance) { CustomOutbox::TestModel.create(identifier:) }
      let!(:fake_model_json) { fake_model_instance.to_json }
      let(:identifier) { SecureRandom.uuid }
      let(:new_identifier) { SecureRandom.uuid }

      context 'when outbox record is created' do
        it { is_expected.to be true }

        it 'updates the record' do
          expect { subject }.to not_change(CustomOutbox::TestModel, :count)
            .and change(fake_model_instance, :identifier).to(new_identifier)
        end

        it 'creates the outbox record' do
          expect { subject }.to change(CustomOutbox::Outbox, :count).by(1)
        end

        it 'creates the outbox record with the correct data' do
          subject
          outbox = CustomOutbox::Outbox.last
          expect(outbox.aggregate).to eq('CustomOutbox::TestModel')
          expect(outbox.aggregate_identifier).to eq(new_identifier)
          expect(outbox.event).to eq('TEST_MODEL_UPDATED.CUSTOM_OUTBOX')
          expect(outbox.identifier).not_to be_nil
          expect(outbox.payload['after'].to_json).to eq(CustomOutbox::TestModel.last.to_json)
          expect(outbox.payload['before'].to_json).to eq(fake_model_json)
        end
      end
    end
  end

  describe '#save!' do
    subject { fake_model_instance.save! }

    let(:identifier) { SecureRandom.uuid }
    let(:fake_model_instance) { CustomOutbox::TestModel.new(identifier:) }

    context 'when record is created' do
      context 'when outbox record is created' do
        it { is_expected.to be true }

        it 'creates the record' do
          expect { subject }.to change(CustomOutbox::TestModel, :count).by(1)
        end

        it 'creates the outbox record' do
          expect { subject }.to change(CustomOutbox::Outbox, :count).by(1)
        end
      end

      context 'when there is a record invalid error when creating the outbox record' do
        before do
          outbox = build(:transactional_outbox_outbox, event: nil)
          allow(CustomOutbox::Outbox).to receive(:new).and_return(outbox)
        end

        it 'raises error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'does not create the record' do
          expect do
            subject
          end.to raise_error(ActiveRecord::RecordInvalid).and not_change(CustomOutbox::TestModel, :count)
        end

        it 'does not create the outbox record' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid).and not_change(CustomOutbox::Outbox, :count)
        end

        it 'adds the errors to the model' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
            .and change { fake_model_instance.errors.messages }.from({}).to({ 'outbox.event': ["can't be blank"] })
        end
      end

      context 'when there is an error when creating the outbox record' do
        before do
          outbox = instance_double(CustomOutbox::Outbox, invalid?: false)
          allow(CustomOutbox::Outbox).to receive(:new).and_return(outbox)
          allow(outbox).to receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
        end

        it 'raises error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotSaved)
        end

        it 'does not create the record' do
          expect do
            subject
          end.to raise_error(ActiveRecord::RecordNotSaved).and not_change(CustomOutbox::TestModel, :count)
        end

        it 'does not create the outbox record' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotSaved).and not_change(CustomOutbox::Outbox, :count)
        end
      end
    end

    context 'when the record could not be created' do
      let(:identifier) { nil }

      it 'raises error' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create the record' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid).and not_change(CustomOutbox::TestModel, :count)
      end

      it 'does not create the outbox record' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid).and not_change(CustomOutbox::Outbox, :count)
      end
    end
  end

  describe '#create' do
    subject { CustomOutbox::TestModel.create(identifier:) }

    let(:identifier) { SecureRandom.uuid }

    context 'when record is created' do
      context 'when outbox record is created' do
        it { is_expected.to eq(CustomOutbox::TestModel.last) }

        it 'creates the record' do
          expect { subject }.to change(CustomOutbox::TestModel, :count).by(1)
        end

        it 'creates the outbox record' do
          expect { subject }.to change(CustomOutbox::Outbox, :count).by(1)
        end

        it 'creates the outbox record with the correct data' do
          subject
          outbox = CustomOutbox::Outbox.last
          expect(outbox.aggregate).to eq('CustomOutbox::TestModel')
          expect(outbox.aggregate_identifier).to eq(identifier)
          expect(outbox.event).to eq('TEST_MODEL_CREATED.CUSTOM_OUTBOX')
          expect(outbox.identifier).not_to be_nil
          expect(outbox.payload['after'].to_json).to eq(CustomOutbox::TestModel.last.to_json)
          expect(outbox.payload['before']).to be_nil
        end
      end
    end
  end

  describe '#update' do
    subject { fake_model.update(identifier: new_identifier) }

    let!(:fake_model) { CustomOutbox::TestModel.create(identifier:) }
    let!(:fake_old_model) { fake_model.to_json }
    let(:identifier) { SecureRandom.uuid }
    let(:new_identifier) { SecureRandom.uuid }

    context 'when record is updated' do
      context 'when outbox record is created' do
        it { is_expected.to be true }

        it 'updates the record' do
          expect { subject }.to not_change(CustomOutbox::TestModel, :count)
            .and change(fake_model, :identifier).to(new_identifier)
        end

        it 'creates the outbox record' do
          expect { subject }.to change(CustomOutbox::Outbox, :count).by(1)
        end

        it 'creates the outbox record with the correct data' do
          subject
          outbox = CustomOutbox::Outbox.last
          expect(outbox.aggregate).to eq('CustomOutbox::TestModel')
          expect(outbox.aggregate_identifier).to eq(new_identifier)
          expect(outbox.event).to eq('TEST_MODEL_UPDATED.CUSTOM_OUTBOX')
          expect(outbox.identifier).not_to be_nil
          expect(outbox.payload['before'].to_json).to eq(fake_old_model)
          expect(outbox.payload['after'].to_json).to eq(fake_model.reload.to_json)
        end
      end
    end
  end

  describe '#destroy' do
    subject { fake_model.destroy }

    let!(:fake_model) { CustomOutbox::TestModel.create(identifier:) }
    let(:identifier) { SecureRandom.uuid }

    context 'when record is destroyed' do
      context 'when outbox record is created' do
        it { is_expected.to eq(fake_model) }

        it 'destroys the record' do
          expect { subject }.to change(CustomOutbox::TestModel, :count).by(-1)
        end

        it 'creates the outbox record' do
          expect { subject }.to change(CustomOutbox::Outbox, :count).by(1)
        end

        it 'creates the outbox record with the correct data' do
          subject
          outbox = CustomOutbox::Outbox.last
          expect(outbox.aggregate).to eq('CustomOutbox::TestModel')
          expect(outbox.aggregate_identifier).to eq(identifier)
          expect(outbox.event).to eq('TEST_MODEL_DESTROYED.CUSTOM_OUTBOX')
          expect(outbox.identifier).not_to be_nil
          expect(outbox.payload['after']).to be_nil
          expect(outbox.payload['before'].to_json).to eq(fake_model.to_json)
        end
      end
    end
  end

end
