require 'csv'
require 'hashie'

def main
  yaml = Hashie::Mash.load("./config.yaml")
  key = yaml.join_key
  input_file = yaml.input.table[0].name
  input2_file = yaml.input.table[1].name
  output_file = yaml.output.table[0].name

  array = []
  array = calc_merge(key, input_file, input2_file)

  File.write(output_file, CSV::Table.new(array))
end

def calc_merge(key, input_file, input2_file)
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

main
