#!/usr/bin/ruby

require "erb"

HELP = <<-HELP
Usage: render-config ERB_TEMPLATE DEST_PATH
Renders template ERB_TEMPLATE to DEST_PATH with erb template engine.

Environment variables are available inside templates with "env" hash
like this:

  some string
  current path is <%= env['PATH'] %> !!!
  some other string

More on ERB syntax here: https://apidock.com/ruby/ERB
HELP

class Config
  attr_reader :env, :template

  def initialize(template, env)
    @template = template
    @env = env
  end
end

class ConfigRenderer
  TEMPLATE_NOT_FOUND_MESSAGE = 'template file not found'
  OUTPUT_FOLDER_NOT_FOUND_MESSAGE = 'output folder does not exist'

  attr_reader :template_filename, :output_filename, :env

  def initialize(template_filename, output_filename, env)
    @template_filename = template_filename
    @output_filename = output_filename
    @env = env
  end

  def render!
    raise TEMPLATE_NOT_FOUND_MESSAGE unless template_exist?
    raise OUTPUT_FOLDER_NOT_FOUND_MESSAGE unless output_dir_exist?

    template = File.read(template_filename)
    rendered_template = build_template(template)
    File.open(output_filename, 'w') { |file| file.write(rendered_template) }
  end

  private

  def build_template(template)
    b = binding
    ERB.new(template).result(b)
  end

  def template_exist?
    template_filename && File.exist?(template_filename)
  end

  def output_dir_exist?
    output_filename && Dir.exist?(File.dirname(output_filename))
  end
end

if ARGV.include?("--help") || ARGV.include?("-h")
  puts HELP
else
  ConfigRenderer.new(ARGV[0], ARGV[1], ENV).render!
end
