require 'erb'
require 'ostruct'

class View < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end
