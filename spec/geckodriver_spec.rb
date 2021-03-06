require "spec_helper"

describe Webdrivers::Geckodriver do

  let(:geckodriver) { Webdrivers::Geckodriver }

  it 'raises exception if unable to get latest geckodriver and no geckodriver present' do
    geckodriver.remove
    allow(geckodriver).to receive(:latest).and_return(nil)
    msg = /^Unable to find the latest version of geckodriver(.exe)?; try downloading manually from (.*)?and place in (.*)?\.webdrivers$/
    expect { geckodriver.update }.to raise_exception StandardError, msg
  end

  it 'uses found version of geckodriver if latest release unable to be found' do
    geckodriver.download
    allow(geckodriver).to receive(:latest).and_return(nil)
    expect(geckodriver.update).to match(/\.webdrivers\/geckodriver/)
  end

  it 'finds latest version' do
    old_version = Gem::Version.new('0.17')
    future_version = Gem::Version.new('0.30')
    latest_version = geckodriver.latest

    expect(latest_version).to be > old_version
    expect(latest_version).to be < future_version
  end

  it 'downloads latest version by default' do
    geckodriver.download
    expect(geckodriver.current).to eq geckodriver.latest
  end

  it 'downloads specified version' do
    geckodriver.remove
    geckodriver.download('0.17.0')
    expect(geckodriver.current.version).to eq '0.17.0'
  end

  it 'removes geckodriver' do
    geckodriver.remove
    expect(geckodriver.current).to be_nil
  end

  context 'when offline' do
    before { allow(geckodriver).to receive(:site_available?).and_return(false) }

    it 'raises exception finding latest version' do
      expect {geckodriver.latest}.to raise_error(StandardError, "Can not reach site")
    end

    it 'raises exception downloading' do
      expect {geckodriver.download}.to raise_error(StandardError, "Can not reach site")
    end
  end

end
