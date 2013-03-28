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

      until @java_command.exit_status
        process_output_io(output)
        process_output_io(error)

        break if block && block.call
      end

      # Hack to make sure we get all the output (probably)
      sleep(3)
      process_output_io(output)
      process_output_io(error)

      @java_command.exit_status
    ensure
      @java_command.close
    end

    private

    def process_output_io(io)
      output_str = Timeout.timeout(0.5) { io.read(1024) }
      @on_output.each { |cb| cb.call(output_str) } if output_str
    rescue EOFError, Timeout::Error
    end
  end
end