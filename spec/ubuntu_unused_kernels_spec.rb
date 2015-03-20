require 'spec_helper'

describe UbuntuUnusedKernels do
  it 'should have a version number' do
    expect(UbuntuUnusedKernels::VERSION).to_not be_nil
  end

  describe 'to_remove' do
    let(:suffix) { 'generic' }

    describe 'one kernel installed, is current and latest' do
      it 'should return nothing' do
        allow(subject).to receive(:get_current).with(no_args).and_return(['3.13.0-43', suffix])
        allow(subject).to receive(:get_installed).with(suffix).and_return(%w{
          linux-image-3.13.0-43-generic
          linux-headers-3.13.0-43-generic
        })

        expect(subject.to_remove).to eq([])
      end
    end

    describe 'five kernels installed' do
      let(:installed) { %w{
        linux-image-3.13.0-39-generic
        linux-image-3.13.0-40-generic
        linux-image-3.13.0-41-generic
        linux-image-3.13.0-42-generic
        linux-image-3.13.0-43-generic
        linux-headers-3.13.0-39-generic
        linux-headers-3.13.0-40-generic
        linux-headers-3.13.0-41-generic
        linux-headers-3.13.0-42-generic
        linux-headers-3.13.0-43-generic
      }}

      describe 'current is latest' do
        it 'should return everything except current/latest' do
          allow(subject).to receive(:get_current).with(no_args).and_return(['3.13.0-43', suffix])
          allow(subject).to receive(:get_installed).with(suffix).and_return(installed)

          expect(subject.to_remove).to match_array(%w{
            linux-image-3.13.0-39-generic

          expect(subject.to_remove).to match_array(%w{
            linux-image-3.13.0-39-generic
            linux-image-3.13.0-40-generic
            linux-image-3.13.0-41-generic
            linux-image-3.13.0-42-generic
            linux-headers-3.13.0-39-generic
            linux-headers-3.13.0-40-generic
            linux-headers-3.13.0-41-generic
            linux-headers-3.13.0-42-generic
          })
        end
      end

      describe 'current is not latest' do
        it 'should return everything except current and latest' do
          allow(subject).to receive(:get_current).with(no_args).and_return(['3.13.0-41', suffix])
          allow(subject).to receive(:get_installed).with(suffix).and_return(installed)

          expect(subject.to_remove).to match_array(%w{
            linux-image-3.13.0-39-generic
            linux-image-3.13.0-40-generic
            linux-image-3.13.0-42-generic
            linux-headers-3.13.0-39-generic
            linux-headers-3.13.0-40-generic
            linux-headers-3.13.0-42-generic
          })
        end
      end

      describe 'unsorted list of kernels' do
        it 'should return everything except current and latest' do
          allow(subject).to receive(:get_current).with(no_args).and_return(['3.13.0-41', suffix])
          allow(subject).to receive(:get_installed).with(suffix).and_return(installed.shuffle)

          expect(subject.to_remove).to match_array(%w{
            linux-image-3.13.0-39-generic
            linux-image-3.13.0-40-generic
            linux-image-3.13.0-42-generic
            linux-headers-3.13.0-39-generic
            linux-headers-3.13.0-40-generic
            linux-headers-3.13.0-42-generic
          })
        end
      end
    end
  end

  describe 'get_current' do
    describe 'normal operation' do
      it 'should return version and suffix' do
        allow(Open3).to receive(:capture2).with('uname', '-r').and_return(
          Open3.capture2('echo', '3.13.0-43-generic')
        )

        expect(subject.get_current).to eq(['3.13.0-43', 'generic'])
      end
    end

    describe 'unable to parse version' do
      it 'should raise exception' do
        allow(Open3).to receive(:capture2).with('uname', '-r').and_return(
          Open3.capture2('echo', '123-generic')
        )

        expect { subject.get_current }.to raise_error(
          RuntimeError, "Unable to determine current kernel"
        )
      end
    end

    describe 'unable to parse suffix' do
      it 'should raise an exception' do
        allow(Open3).to receive(:capture2).with('uname', '-r').and_return(
          Open3.capture2('echo', '3.13.0-43')
        )

        expect { subject.get_current }.to raise_error(
          RuntimeError, "Unable to determine current kernel"
        )
      end
    end

    describe 'command returns correct output but non-zero exit code' do
      it 'should raise exception' do
        allow(Open3).to receive(:capture2).with('uname', '-r').and_return(
          Open3.capture2('bash', '-c', 'echo 3.13.0-43-generic; exit 1')
        )

        expect { subject.get_current }.to raise_error(
          RuntimeError, "Unable to determine current kernel"
        )
      end
    end
  end
end
