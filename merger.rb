require 'csv'
require 'hashie'

def main(yaml)
  array = []

  # merge
  array = calc_merge(
    key: yaml.join_key,
    input_file: yaml.input.table[0].name,
    input2_file: yaml.input.table[1].name
  )

  # extract
  array = extract_array(
    source: array,
    columns: yaml.output.table[0].columns.to_a
  )

  # output
  File.write(yaml.output.table[0].name, CSV::Table.new(array))
end

def extract_array(source:, columns:)
  source.each do |r|
    r.delete_if { |header, _| !columns.include?(header) }
  end
  return source
end

def calc_merge(key:, input_file:, input2_file:)
  key_index = CSV.read(input_file)[0].index(key)
  key_index2 =CSV.read(input2_file)[0].index(key)
  array = []
  CSV.foreach(input_file, headers: true) do |row|
    CSV.foreach(input2_file, headers: true) do |row2|
      if row[key_index] == row2[key_index2]
        row2.delete(key_index2)
        row << row2.to_h
        array << row
      end
    end
  end
  return array
end

main Hashie::Mash.load("./config.yaml")
