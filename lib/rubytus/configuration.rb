module Rubytus
  class Configuration
    attr_accessor :data_dir
    attr_accessor :max_size
    attr_accessor :base_path

    def initialize
      @data_dir  = ENV.fetch('TUSD_DATA_DIR', 'tus_data')
      @max_size  = ENV.fetch('TUSD_DATASTORE_MAX_SIZE', 1024 * 1024 * 1024)
      @base_path = ENV.fetch('TUSD_BASEPATH', '/files/')
    end
  end
end
