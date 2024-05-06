
class ParserJson
  def initialize
    @stack = []
    @json = {}
  end

  def set_value(key, value)
    @json[key] = value
  end

  def print_json
    puts @json
  end

  def parse(json)
    # temp variables
    temp_key = ''
    temp_value = ''
    temp_array = []
    temp_hash = {}
    temp_object_key = ''
    temp_array_active = false
    temp_hash_active = false
    temp_number_active = false

    state = :q0

    json.split(" ").join("").each_char.with_index do |char, index|

      case [state, char, @stack.last]

      # start json
      in [:q0, '{', _]
        @stack.push('$')
        state = :q1

      # initalize json or an object
      in [:q1, '"', _]
        @stack.push('i')
        state = :q3

      # in [:q2, /[a-zA-Z]/, _]
      #  temp_key << char
      #  state = :q3

      in [:q3, /[a-zA-Z]/, _]
        if temp_hash_active
          temp_object_key << char
        else
          temp_key << char
        end
        state = :q3

      in [:q3, '"', 'i']
        @stack.pop
        state = :q4

      in [:q4, ':', _]
        @stack.push('e')
        state = :q5

      # object case
      in [:q5, '{', last]
        temp_hash_active = true

        if last == 'e'
          @stack.pop
        end

        @stack.push('o')
        state = :q6

      in [:q6, '"', _]
        @stack.push('i')
        state = :q3

      in [:q6, '}', 'o']
        temp_hash_active = false

        @stack.pop
        state = :q20

      # array case
      in [:q5, '[', last]
        temp_array_active = true

        if last == 'e'
          @stack.pop
        end

        @stack.push('a')
        state = :q5

      in [:q5, ']', 'a']
        @stack.pop
        state = :q20

      # string cases
      in [:q5, '"', last]
        if last == 'e'
          @stack.pop
        end

        @stack.push('s')
        state = :q7

      in [:q7, /\w/, _]
        temp_value << char
        state = :q7

      in [:q7, '"', 's']
        if temp_array_active
          temp_array.push(temp_value)
        elsif temp_hash_active
          temp_hash[temp_object_key] = temp_value
          temp_object_key = ''
        else
          set_value(temp_key, temp_value)
          temp_key = ''
        end
        temp_value = ''

        @stack.pop
        state = :q20

      in [:q5, '\'', last]
        if last == 'e'
          @stack.pop
        end

        @stack.push('s')
        state = :q8

      in [:q8, /\w/, _]
        temp_value << char
        state = :q7

      in [:q8, '\'', 's']
        if temp_array_active
          temp_array.push(temp_value)
        elsif temp_hash_active
          temp_hash[temp_object_key] = temp_value
          temp_object_key = ''
        else
          set_value(temp_key, temp_value)
          temp_key = ''
        end
        temp_value = ''

        @stack.pop
        state = :q20

      # number cases
      in [:q5, /[0-9]/, last]
        temp_number_active = true
        temp_value << char

        if last == 'e'
          @stack.pop
        end

        @stack.push('d')
        state = :q19

      in [:q19, /[0-9]/, _]
        temp_value << char

        state = :q19

      in [:q19, '.', 'd']
        temp_value << char

        @stack.pop
        state = :q21

      in [:q21, /[0-9]/, _]
        temp_value << char

        state = :q19

      # boolean cases
      in [:q5, 't', last]
        if last == 'e'
          @stack.pop
        end

        @stack.push('t')
        state = :q9

      in [:q9, 'r', _]
        state = :q10

      in [:q10, 'u', _]
        state = :q11

      in [:q11, 'e', 't']
        if temp_array_active
          temp_array.push(true)
        elsif temp_hash_active
          temp_hash[temp_object_key] = true
          temp_object_key = ''
        else
          set_value(temp_key, true)
          temp_key = ''
        end
        temp_value = ''

        @stack.pop
        state = :q20

      in [:q5, 'f', last]
        if last == 'e'
          @stack.pop
        end

        @stack.push('f')
        state = :q12

      in [:q12, 'a', _]
        state = :q13

      in [:q13, 'l', _]
        state = :q14

      in [:q14, 's', _]
        state = :q15

      in [:q15, 'e', 'f']
        if temp_array_active
          temp_array.push(false)
        elsif temp_hash_active
          temp_hash[temp_object_key] = false
          temp_object_key = ''
        else
          set_value(temp_key, false)
          temp_key = ''
        end
        temp_value = ''

        @stack.pop
        state = :q20

      in [:q5, 'n', last]
        if last == 'e'
          @stack.pop
        end

        @stack.push('n')
        state = :q16

      in [:q16, 'u', _]
        state = :q17

      in [:q17, 'l', _]
        state = :q18

      in [:q18, 'l', 'n']
        if temp_array_active
          temp_array.push(nil)
        elsif temp_hash_active
          temp_hash[temp_object_key] = nil
          temp_object_key = ''
        else
          set_value(temp_key, nil)
          temp_key = ''
        end
        temp_value = ''

        @stack.pop
        state = :q20

      # finish cases

      # empty json
      in [:q1, '}', '$']
        @stack.pop
        state = :q22

      in [:q19 | :q20, ',', last]
        if temp_number_active == true
          if last == 'd'
            number = temp_value.to_i
          else
            number = temp_value.to_f
          end

          if temp_array_active
            temp_array.push(number)
          elsif temp_hash_active
            temp_hash[temp_object_key] = number
            temp_object_key = ''
          else
            set_value(temp_key, number)
            temp_key = ''
          end
          temp_value = ''

          temp_number_active = false
        end

        if last == 'd'
          @stack.pop
          last = @stack.last
        end

        if last == 'o' || last == '$'
          state = :q1
        else
          @stack.push('e')
          state = :q5
        end

      in [:q19 | :q20, ']', last]
        if temp_number_active == true
          if last == 'd'
            number = temp_value.to_i
          else
            number = temp_value.to_f
          end

          if temp_array_active
            temp_array.push(number)
          else
            set_value(temp_key, number)
            temp_key = ''
          end
          temp_value = ''

          temp_number_active = false
        end

        if last == 'd'
          @stack.pop
          last = @stack.last
        end

        if last == 'a'
          set_value(temp_key, temp_array)
            temp_array = []
            temp_array_active = false
            temp_key = ''

          @stack.pop
        end

        state = :q20

      in [:q19 | :q20, '}', last]
        if temp_number_active == true
          if last == 'd'
            number = temp_value.to_i
          else
            number = temp_value.to_f
          end

          if temp_array_active
            temp_array.push(number)
          elsif temp_hash_active
            temp_hash[temp_object_key] = number
            temp_object_key = ''
          else
            set_value(temp_key, number)
            temp_key = ''
          end
          temp_value = ''

          temp_number_active = false
        end

        if last == 'd'
          @stack.pop
          last = @stack.last
        end

        if last == 'o'
          set_value(temp_key, temp_hash)
          temp_key = ''
          temp_hash = {}
          @stack.pop
        elsif last == '$'
          state = :q22
          @stack.pop
        end

        state = :q20

      else
        puts "Error - Json inválido"
        puts "Indice da origem do erro: #{index}"
        puts "Erro com base na pilha: '#{track_error(@stack.last)}'"
        break
      end

    end

    if @stack.empty?
      print_json
    else
      puts "Error - Json inválido"
      puts "Erro com base na pilha: '#{track_error(@stack.last)}'"
    end

  end

  def track_error(last)
    error_message = ''

    case [last]

    in ['i']
      error_message = "Estrutura ou nomeclatura do nome da key"

    in ['e']
      error_message = "Expectativa de entrada de algum valor"

    in ['s']
      error_message = "Estrtura ou nomeclatura da string"

    in ['o']
      error_message = "Estrutura do objeto"

    in ['a']
      error_message = "Estrutura do array"

    in ['d']
      error_message = "Estrtura do número"

    in ['t']
      error_message = "Estrutura ou nomeclatura do boolean true"

    in ['f']
      error_message = "Estrutura ou nomeclatura do boolean false"

    in ['n']
      error_message = "Estrutura ou nomeclatura do boolean null"

    else
      error_message = "Estrutura do Json"
    end

    return error_message
  end
end
