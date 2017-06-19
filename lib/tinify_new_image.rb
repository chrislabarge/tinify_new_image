require "tinify_new_image/version"
require "tinify"
require "listen"

module TinifyNewImage
  INVALID_DIRECTORY = 'The directory is invalid'
  INVALID_FILE = 'It is not a valid "JPEG" or "PNG" file'

  def self.test
    true
  end

  def self.watch_dir(dir)
    unless File.directory?(dir)
      puts INVALID_DIRECTORY
      return
    end

    files = Dir["#{dir}/**/*"]

    #TODO maybe come up with some logic to include modifying an image.  Right now it goes into a loop

    listener = Listen.to(dir) do |modified, added|
      # (modified + added).each do |file_name|
      added.each do |file_name|
        optimize_image_file(file_name)
      end
    end

    start_watching(listener, dir)
  end

  def self.start_watching(listener, dir)
    begin
      listener.start
      puts "Watching  #{dir} directory"
      sleep
    rescue SystemExit, Interrupt
      raise ''
    rescue Exception => e
      puts ''
      puts "Error: #{e}"
      puts "No longer watching #{dir} directory"
      listener.stop
      raise e
    end
  end

  def self.optimize_image_file(file)
    extensions = ['.jpg','.jpeg', '.png']

    extension = File.extname(file)

    unless extensions.include?(extension)
      puts "Unable to optimize #{file}. #{INVALID_FILE}"
      return
    end

    puts "optimizing img #{file}..."

    @optimizer = initialize_optimizer unless @optimizer

    Dir.mkdir 'original-images' unless File.directory?('original-images')

    new_path = 'original-images/' + File.basename(file)

    File.rename file, new_path

    begin
      @optimizer.from_file(new_path).to_file(file)
    rescue => e
      #merge this message with the extension one
      puts "Unsuccessfully optimized image #{file}"
      puts "Optimizing Service Error: #{e}"
      return
    end

    puts "Successfully optimized image #{file}!"
    puts "Compressed #{@optimizer.compression_count} images so far this month!"
  end

  def self.initialize_optimizer
    Tinify.key = '6Ec_CRuqcmdkEPY1KAb3Yq2OeI4tbnO0'
    Tinify
  end
end
