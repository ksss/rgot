# Output:
# bad output
module ExamplePassTest
  # Output:
  # bad output
  def example_singleline
    puts "ok go"
    # Output: ng back
  end

  def example_multiline
    puts "Hello"
    puts "I'm example"
    # Output:
    # bye
    # I'm fail
  end
  # Output:
  # bad output
end
# Output:
# bad output
