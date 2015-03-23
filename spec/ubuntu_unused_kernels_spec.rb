require 'spec_helper'

describe UbuntuUnusedKernels do
  it 'should have a version number' do
    expect(UbuntuUnusedKernels::VERSION).to_not be_nil
  end

  describe 'to_remove' do
    describe 'one kernel installed, is current and latest' do
      it 'should return nothing' do
        allow(subject).to receive(:get_current).with(no_args).and_return('3.13.0-43')
        allow(subject).to receive(:get_installed).with(no_args).and_return(%w{
          linux-headers-3.13.0-43
          linux-headers-3.13.0-43-generic
          linux-image-3.13.0-43-generic
        })

        expect(subject.to_remove).to eq([])
      end
    end

    describe 'five kernels installed' do
      let(:installed) { %w{
        linux-headers-3.13.0-39
        linux-headers-3.13.0-39-generic
        linux-headers-3.13.0-40
        linux-headers-3.13.0-40-generic
        linux-headers-3.13.0-41
        linux-headers-3.13.0-41-generic
        linux-headers-3.13.0-42
        linux-headers-3.13.0-42-generic
        linux-headers-3.13.0-43
        linux-headers-3.13.0-43-generic
        linux-image-3.13.0-39-generic
        linux-image-3.13.0-40-generic
        linux-image-3.13.0-41-generic
        linux-image-3.13.0-42-generic
        linux-image-3.13.0-43-generic
      }}

      describe 'current is latest' do
        it 'should return everything except current/latest' do
          allow(subject).to receive(:get_current).with(no_args).and_return('3.13.0-43')
          allow(subject).to receive(:get_installed).with(no_args).and_return(installed)

          expect(subject.to_remove).to match_array(%w{
            linux-headers-3.13.0-39
            linux-headers-3.13.0-39-generic
            linux-headers-3.13.0-40
            linux-headers-3.13.0-40-generic
            linux-headers-3.13.0-41
            linux-headers-3.13.0-41-generic
            linux-headers-3.13.0-42
            linux-headers-3.13.0-42-generic
            linux-image-3.13.0-39-generic
            linux-image-3.13.0-40-generic
            linux-image-3.13.0-41-generic
            linux-image-3.13.0-42-generic
          })
        end
      end

      describe 'current is not latest' do
        it 'should return everything except current and latest' do
          allow(subject).to receive(:get_current).with(no_args).and_return('3.13.0-41')
          allow(subject).to receive(:get_installed).with(no_args).and_return(installed)

          expect(subject.to_remove).to match_array(%w{
            linux-headers-3.13.0-39
            linux-headers-3.13.0-39-generic
            linux-headers-3.13.0-40
            linux-headers-3.13.0-40-generic
            linux-headers-3.13.0-42
            linux-headers-3.13.0-42-generic
            linux-image-3.13.0-39-generic
            linux-image-3.13.0-40-generic
            linux-image-3.13.0-42-generic
          })
        end
      end

      describe 'unsorted list of kernels' do
        it 'should return everything except current and latest' do
          allow(subject).to receive(:get_current).with(no_args).and_return('3.13.0-41')
          allow(subject).to receive(:get_installed).with(no_args).and_return(installed.shuffle)

          expect(subject.to_remove).to match_array(%w{
            linux-headers-3.13.0-39
            linux-headers-3.13.0-39-generic
            linux-headers-3.13.0-40
            linux-headers-3.13.0-40-generic
            linux-headers-3.13.0-42
            linux-headers-3.13.0-42-generic
            linux-image-3.13.0-39-generic
            linux-image-3.13.0-40-generic
            linux-image-3.13.0-42-generic
          })
        end
      end
    end
  end

  describe 'get_current' do
    describe 'normal operation' do
      it 'should return version without suffix' do
        allow(Open3).to receive(:capture2).with('uname', '-r').and_return(
          Open3.capture2('echo', '3.13.0-43-generic')
        )

        expect(subject.get_current).to eq('3.13.0-43')
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

  describe 'get_installed' do
    describe 'three kernels installed' do
      let(:installed) { <<EOS
linux-headers-3.13.0-41
linux-headers-3.13.0-41-generic
linux-headers-3.13.0-42
linux-headers-3.13.0-42-generic
linux-headers-3.13.0-43
linux-headers-3.13.0-43-generic
linux-image-3.13.0-41-generic
linux-image-3.13.0-42-generic
linux-image-3.13.0-43-generic
EOS
      }

      it 'should return an array of six packages' do
        allow(Open3).to receive(:capture2).with(
          'dpkg-query', '--show',
          '--showformat', '${Package}\n',
          'linux-image-*.*.*-*', 'linux-headers-*.*.*-*',
        ).and_return(
          Open3.capture2('echo', installed)
        )

        expect(subject.get_installed()).to match_array(%w{
          linux-headers-3.13.0-41
          linux-headers-3.13.0-41-generic
          linux-headers-3.13.0-42
          linux-headers-3.13.0-42-generic
          linux-headers-3.13.0-43
          linux-headers-3.13.0-43-generic
          linux-image-3.13.0-41-generic
          linux-image-3.13.0-42-generic
          linux-image-3.13.0-43-generic
        })
      end
    end

    describe 'no kernels installed' do
      it 'should raise an exception because current or latest should be present' do
        allow(Open3).to receive(:capture2).with(any_args).and_return(
          Open3.capture2('echo')
        )

        expect { subject.get_installed() }.to raise_error(
          RuntimeError, "No kernel packages found"
        )
      end
    end

    describe 'command returns non-zero exit code' do
      it 'should raise an exception' do
        allow(Open3).to receive(:capture2).with(any_args).and_return(
          Open3.capture2('bash', '-c', 'echo foo; exit 1')
        )

        expect { subject.get_installed() }.to raise_error(
          RuntimeError, "Unable to get list of packages"
        )
      end
    end
  end
end
