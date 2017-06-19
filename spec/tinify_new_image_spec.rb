require "spec_helper"

describe TinifyNewImage do
  dir = 'tmp/testing'

  # let(:dir) {'testing'}

  before(:all) do
    Dir.mkdir dir unless File.directory?(dir)
  end

  after(:all) do
    FileUtils.rm_rf(dir)
  end

  it "has a version number" do
    expect(TinifyNewImage::VERSION).not_to be nil
  end

  it "does something useful" do
    actual = subject.test()
    expect(actual).to eq(true)
  end

  context '#watch_dir' do
    before do
      allow(subject).to receive(:puts)
    end

    it 'calls sleep' do
      allow(subject).to receive(:sleep)

      actual = subject.watch_dir(dir)

      expect(subject).to have_received(:sleep)
    end

    it 'puts "no directory msg"' do
      actual = subject.watch_dir('not_a_directory')

      expect(subject).to have_received(:puts).with(subject::INVALID_DIRECTORY)
    end
  end

  context '#optimize_image_file' do
    before do
      allow(subject).to receive(:puts)
    end

    it 'puts "INVALID_FILE msg"' do
      file = 'invalid_file'
      expected = "Unable to optimize #{file}. #{subject::INVALID_FILE}"
      subject.optimize_image_file(file)
      expect(subject).to have_received(:puts).with(expected)
    end


    let(:optimizer) { double('optimizer') }

    it 'successfully optimizes an image' do
      allow(subject).to receive(:initialize_optimizer) { optimizer }
      allow(optimizer).to receive(:from_file) { optimizer }
      allow(optimizer).to receive(:to_file) {}
      allow(optimizer).to receive(:compression_count) { }

      file = 'foo.jpg'

      File.open(file, "w") {}

      expected = "Successfully optimized image #{file}!"
      subject.optimize_image_file(file)
      expect(subject).to have_received(:puts).with(expected)
    end

    let(:optimizer) { Tinify }

    it 'unsuccessfully optimizes an image' do
      allow(subject).to receive(:initialize_optimizer) { optimizer }
      allow(optimizer).to receive(:from_file) { optimizer }
      allow(optimizer).to receive(:to_file) { raise Tinify::ClientError }

      file = 'foo.jpg'

      File.open(file, "w") {}

      expected = "Unsuccessfully optimized image #{file}"
      subject.optimize_image_file(file)
      expect(subject).to have_received(:puts).with(expected)
    end
  end
end

