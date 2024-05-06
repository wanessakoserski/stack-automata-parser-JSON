
class ParserJson
  def initialize
    @stack = []
    @json = {}
  end

  def set_value(key, value)
    @json[key] = value
  end

  def pa
    puts @json
  end

  def parse(json)
    # temp variables
    temp_key = ''
    temp_value = ''
    temp_array_active = false
    temp_hash_active = false
    temp_number_active = false

    state = :q0

    json.split(" ").join("").each_char do |char|

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
        temp_key << char
        state = :q3

      in [:q3, '"', 'i']
        @stack.pop
        state = :q4

      in [:q4, ':', _]
        @stack.push('e')
        state = :q5

      # object case
      in [:q5, '{', last]
        if last == 'e'
          @stack.pop
        end

        @stack.push('o')
        state = :q6

      in [:q6, '"', _]
        @stack.push('i')
        state = :q2

      in [:q6, '}', 'o']
        @stack.pop
        state = :q20

      # array case
      in [:q5, '[', last]
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
        set_value(temp_key, temp_value)
        temp_key = ''
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
        set_value(temp_key, temp_value)
        temp_key = ''
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
        set_value(temp_key, true)
        temp_key = ''
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
        set_value(temp_key, false)
        temp_key = ''
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
        set_value(temp_key, nil)
        temp_key = ''
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
            set_value(temp_key, temp_value.to_i)
          else
            set_value(temp_key, temp_value.to_f)
          end

          temp_number_active = false
          temp_key = ''
          temp_value = ''
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
            set_value(temp_key, temp_value.to_i)
          else
            set_value(temp_key, temp_value.to_f)
          end

          temp_number_active = false
          temp_key = ''
          temp_value = ''
        end

        if last == 'd'
          @stack.pop
          last = @stack.last
        end

        if last == 'a'
          @stack.pop
        end

        state = :q20

      in [:q19 | :q20, '}', last]
        if temp_number_active == true
          if last == 'd'
            set_value(temp_key, temp_value.to_i)
          else
            set_value(temp_key, temp_value.to_f)
          end

          temp_number_active = false
          temp_key = ''
          temp_value = ''
        end

        if last == 'd'
          @stack.pop
          last = @stack.last
        end

        if last == 'o'
          @stack.pop
        elsif last == '$'
          state = :q22
          @stack.pop
        end

        state = :q20

      else
        puts 'Error'
        break
      end

    end

  end
end
