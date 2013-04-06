module SSHJr
  # Wraps a Session.Command java object and gives it a more ruby-like API
  class Command
    def initialize(java_command)
      @java_command = java_command
      @on_output = []
    end

    # Add a callback to be called when output is received for the command.
    #
    # block - The callback block. The block will be given a String object
    #         containing the data received since the last time the callback
    #         was called.
    def on_output(&block)
      @on_output << block
    end

    # This will process the IO for the command.
    #
    # block - A block that will be called regularly (at least once) throughout
    #         the processing. If the block returns true, the method will stop
    #         processing.
    #
    # Returns the exit status of the command
    def process(&block)
      output = @java_command.input_stream.to_io
      error = @java_command.error_stream.to_io

      until output.eof? && error.eof?
        read, write, err = IO.select([output, error], [], [], 1.0)
        read.each do |io|
          str = io.read(1024)
          @on_output.each { |cb| cb.call(str) } if str
        end

        break if block && block.call
      end

      @java_command.exit_status
    ensure
      @java_command.close
    end
  end
end
