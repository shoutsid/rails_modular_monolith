# frozen_string_literal: true

# require 'rails_helper'

RSpec.describe TransactionalOutbox::Outboxable do
  include_examples 'when using component specific Outbox model'

  context 'when using default TransactionalOutbox::Outbox model' do
    describe '#save' do
      subject { fake_model_instance.save }

      let(:fake_model_instance) { DefaultOutbox::TestModel.new(identifier:) }
      let(:identifier) { SecureRandom.uuid }

      context 'when record is created' do
        context 'when outbox record is created' do
          it { is_expected.to be true }

          it 'creates the record' do
            expect { subject }.to change(DefaultOutbox::TestModel, :count).by(1)
          end

          it 'creates the outbox record' do
            expect { subject }.to change(TransactionalOutbox::Outbox, :count).by(1)
          end

          it 'creates the outbox record with the correct data' do
            subject
            outbox = TransactionalOutbox::Outbox.last
            expect(outbox.aggregate).to eq('DefaultOutbox::TestModel')
            expect(outbox.aggregate_identifier).to eq(identifier)
            expect(outbox.event).to eq('TEST_MODEL_CREATED.DEFAULT_OUTBOX')
            expect(outbox.identifier).not_to be_nil
            expect(outbox.payload['after'].to_json).to eq(DefaultOutbox::TestModel.last.to_json)
            expect(outbox.payload['before']).to be_nil
          end
        end

        context 'when there is a record invalid error when creating the outbox record' do
          before do
            outbox = build(:transactional_outbox_outbox, event: nil)
            allow(TransactionalOutbox::Outbox).to receive(:new).and_return(outbox)
          end

          it { is_expected.to be false }

          it 'does not create the record' do
            expect { subject }.not_to change(DefaultOutbox::TestModel, :count)
          end

          it 'does not create the outbox record' do
            expect { subject }.not_to change(TransactionalOutbox::Outbox, :count)
          end

          it 'adds the errors to the model' do
            expect { subject }.to change {
                                    fake_model_instance.errors.messages
                                  }.from({}).to({ 'outbox.event': ["can't be blank"] })
          end
        end

        context 'when there is an error when creating the outbox record' do
          before do
            outbox = instance_double(TransactionalOutbox::Outbox, invalid?: false)
            allow(TransactionalOutbox::Outbox).to receive(:new).and_return(outbox)
            allow(outbox).to receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
          end

          it 'raises error' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotSaved)
          end

          it 'does not create the record' do
            expect do
              subject
            end.to raise_error(ActiveRecord::RecordNotSaved).and not_change(DefaultOutbox::TestModel, :count)
          end

          it 'does not create the outbox record' do
            expect do
              subject
            end.to raise_error(ActiveRecord::RecordNotSaved).and not_change(TransactionalOutbox::Outbox, :count)
          end
        end
      end

      context 'when the record could not be created' do
        let(:identifier) { nil }

        it { is_expected.to be false }

        it 'does not create the record' do
          expect { subject }.not_to change(DefaultOutbox::TestModel, :count)
        end

        it 'does not create the outbox record' do
          expect { subject }.not_to change(TransactionalOutbox::Outbox, :count)
        end
      end

      context 'when record is updated' do
        subject do
          fake_model_instance.identifier = new_identifier
          fake_model_instance.save
        end

        let(:fake_model_instance) { DefaultOutbox::TestModel.create(identifier:) }
        let!(:fake_model_json) { fake_model_instance.to_json }
        let(:identifier) { SecureRandom.uuid }
        let(:new_identifier) { SecureRandom.uuid }

        context 'when outbox record is created' do
          it { is_expected.to be true }

          it 'updates the record' do
            expect { subject }.to not_change(DefaultOutbox::TestModel, :count)
              .and change(fake_model_instance, :identifier).to(new_identifier)
          end

          it 'creates the outbox record' do
            expect { subject }.to change(TransactionalOutbox::Outbox, :count).by(1)
          end

          it 'creates the outbox record with the correct data' do
            subject
            outbox = TransactionalOutbox::Outbox.last
            expect(outbox.aggregate).to eq('DefaultOutbox::TestModel')
            expect(outbox.aggregate_identifier).to eq(new_identifier)
            expect(outbox.event).to eq('TEST_MODEL_UPDATED.DEFAULT_OUTBOX')
            expect(outbox.identifier).not_to be_nil
            expect(outbox.payload['after'].to_json).to eq(DefaultOutbox::TestModel.last.to_json)
            expect(outbox.payload['before'].to_json).to eq(fake_model_json)
          end
        end
      end
    end

    describe '#save!' do
      subject { fake_model_instance.save! }

      let(:identifier) { SecureRandom.uuid }
      let(:fake_model_instance) { DefaultOutbox::TestModel.new(identifier:) }

      context 'when record is created' do
        context 'when outbox record is created' do
          it { is_expected.to be true }

          it 'creates the record' do
            expect { subject }.to change(DefaultOutbox::TestModel, :count).by(1)
          end

          it 'creates the outbox record' do
            expect { subject }.to change(TransactionalOutbox::Outbox, :count).by(1)
          end
        end

        context 'when there is a record invalid error when creating the outbox record' do
          before do
            outbox = build(:transactional_outbox_outbox, event: nil)
            allow(TransactionalOutbox::Outbox).to receive(:new).and_return(outbox)
          end

          it 'raises error' do
            expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
          end

          it 'does not create the record' do
            expect do
              subject
            end.to raise_error(ActiveRecord::RecordInvalid).and not_change(DefaultOutbox::TestModel, :count)
          end

          it 'does not create the outbox record' do
            expect do
              subject
            end.to raise_error(ActiveRecord::RecordInvalid).and not_change(TransactionalOutbox::Outbox, :count)
          end

          it 'adds the errors to the model' do
            expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
              .and change { fake_model_instance.errors.messages }.from({}).to({ 'outbox.event': ["can't be blank"] })
          end
        end

        context 'when there is an error when creating the outbox record' do
          before do
            outbox = instance_double(TransactionalOutbox::Outbox, invalid?: false)
            allow(TransactionalOutbox::Outbox).to receive(:new).and_return(outbox)
            allow(outbox).to receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
          end

          it 'raises error' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotSaved)
          end

          it 'does not create the record' do
            expect do
              subject
            end.to raise_error(ActiveRecord::RecordNotSaved).and not_change(DefaultOutbox::TestModel, :count)
          end

          it 'does not create the outbox record' do
            expect do
              subject
            end.to raise_error(ActiveRecord::RecordNotSaved).and not_change(TransactionalOutbox::Outbox, :count)
          end
        end
      end

      context 'when the record could not be created' do
        let(:identifier) { nil }

        it 'raises error' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'does not create the record' do
          expect do
            subject
          end.to raise_error(ActiveRecord::RecordInvalid).and not_change(DefaultOutbox::TestModel, :count)
        end

        it 'does not create the outbox record' do
          expect do
            subject
          end.to raise_error(ActiveRecord::RecordInvalid).and not_change(TransactionalOutbox::Outbox, :count)
        end
      end
    end

    describe '#create' do
      subject { DefaultOutbox::TestModel.create(identifier:) }

      let(:identifier) { SecureRandom.uuid }

      context 'when record is created' do
        context 'when outbox record is created' do
          it { is_expected.to eq(DefaultOutbox::TestModel.last) }

          it 'creates the record' do
            expect { subject }.to change(DefaultOutbox::TestModel, :count).by(1)
          end

          it 'creates the outbox record' do
            expect { subject }.to change(TransactionalOutbox::Outbox, :count).by(1)
          end

          it 'creates the outbox record with the correct data' do
            subject
            outbox = TransactionalOutbox::Outbox.last
            expect(outbox.aggregate).to eq('DefaultOutbox::TestModel')
            expect(outbox.aggregate_identifier).to eq(identifier)
            expect(outbox.event).to eq('TEST_MODEL_CREATED.DEFAULT_OUTBOX')
            expect(outbox.identifier).not_to be_nil
            expect(outbox.payload['after'].to_json).to eq(DefaultOutbox::TestModel.last.to_json)
            expect(outbox.payload['before']).to be_nil
          end
        end
      end
    end

    describe '#update' do
      subject { fake_model.update(identifier: new_identifier) }

      let!(:fake_model) { DefaultOutbox::TestModel.create(identifier:) }
      let!(:fake_old_model) { fake_model.to_json }
      let(:identifier) { SecureRandom.uuid }
      let(:new_identifier) { SecureRandom.uuid }

      context 'when record is updated' do
        context 'when outbox record is created' do
          it { is_expected.to be true }

          it 'updates the record' do
            expect { subject }.to not_change(DefaultOutbox::TestModel, :count)
              .and change(fake_model, :identifier).to(new_identifier)
          end

          it 'creates the outbox record' do
            expect { subject }.to change(TransactionalOutbox::Outbox, :count).by(1)
          end

          it 'creates the outbox record with the correct data' do
            subject
            outbox = TransactionalOutbox::Outbox.last
            expect(outbox.aggregate).to eq('DefaultOutbox::TestModel')
            expect(outbox.aggregate_identifier).to eq(new_identifier)
            expect(outbox.event).to eq('TEST_MODEL_UPDATED.DEFAULT_OUTBOX')
            expect(outbox.identifier).not_to be_nil
            expect(outbox.payload['before'].to_json).to eq(fake_old_model)
            expect(outbox.payload['after'].to_json).to eq(fake_model.reload.to_json)
          end
        end
      end
    end

    describe '#destroy' do
      subject { fake_model.destroy }

      let!(:fake_model) { DefaultOutbox::TestModel.create(identifier:) }
      let(:identifier) { SecureRandom.uuid }

      context 'when record is destroyed' do
        context 'when outbox record is created' do
          it { is_expected.to eq(fake_model) }

          it 'destroys the record' do
            expect { subject }.to change(DefaultOutbox::TestModel, :count).by(-1)
          end

          it 'creates the outbox record' do
            expect { subject }.to change(TransactionalOutbox::Outbox, :count).by(1)
          end

          it 'creates the outbox record with the correct data' do
            subject
            outbox = TransactionalOutbox::Outbox.last
            expect(outbox.aggregate).to eq('DefaultOutbox::TestModel')
            expect(outbox.aggregate_identifier).to eq(identifier)
            expect(outbox.event).to eq('TEST_MODEL_DESTROYED.DEFAULT_OUTBOX')
            expect(outbox.identifier).not_to be_nil
            expect(outbox.payload['after']).to be_nil
            expect(outbox.payload['before'].to_json).to eq(fake_model.to_json)
          end
        end
      end
    end
  end
end
