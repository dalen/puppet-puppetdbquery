# A butchered version of mcollectives scanner minus regex and functions support
class PuppetDB
  module Matcher
    class Scanner
      attr_accessor :arguments, :token_index

      def initialize(arguments)
        @token_index = 0
        @arguments = arguments.split("")
        @seperation_counter = 0
        @white_spaces = 0
      end

      # Scans the input string and identifies single language tokens
      def get_token
        if @token_index >= @arguments.size
          return nil
        end

        case @arguments[@token_index]
        when "("
          return "(", "("

        when ")"
          return ")", ")"

        when "n"
          if (@arguments[@token_index + 1] == "o") && (@arguments[@token_index + 2] == "t") && ((@arguments[@token_index + 3] == " ") || (@arguments[@token_index + 3] == "("))
            @token_index += 2
            return "not", "not"
          else
            gen_statement
          end

        when "!"
          return "not", "not"

        when "a"
          if (@arguments[@token_index + 1] == "n") && (@arguments[@token_index + 2] == "d") && ((@arguments[@token_index + 3] == " ") || (@arguments[@token_index + 3] == "("))
            @token_index += 2
            return "and", "and"
          else
            gen_statement
          end

        when "o"
          if (@arguments[@token_index + 1] == "r") && ((@arguments[@token_index + 2] == " ") || (@arguments[@token_index + 2] == "("))
            @token_index += 1
            return "or", "or"
          else
            gen_statement
          end

        when " "
          return " ", " "

        else
          gen_statement
        end
      end

      private
      # Helper generates a statement token
      def gen_statement
        func = false
        current_token_value = ""
        j = @token_index

        begin
          if (@arguments[j] =~ /=|<|>/)
            while !(@arguments[j] =~ /=|<|>/)
              current_token_value << @arguments[j]
              j += 1
            end

            current_token_value << @arguments[j]
            j += 1

            while (j < @arguments.size) && ((@arguments[j] != " ") && (@arguments[j] != ")"))
              current_token_value << @arguments[j]
              j += 1
            end
          else
            begin
              if @arguments[j+1] == "("
                func = true
                be_greedy = true
              end
              current_token_value << @arguments[j]
              if be_greedy
                while !(j+1 >= @arguments.size) && @arguments[j] != ')'
                  j += 1
                  current_token_value << @arguments[j]
                end
                j += 1
                be_greedy = false
              else
                j += 1
              end
              if(@arguments[j] == ' ')
                break if(is_klass?(j) && !(@arguments[j-1] =~ /=|<|>/))
              end
              if( (@arguments[j] == ' ') && (@seperation_counter < 2) && !(current_token_value.match(/^.+(=|<|>).+$/)) )
                if((index = lookahead(j)))
                  j = index
                end
              end
            end until (j >= @arguments.size) || (@arguments[j] =~ /\s|\)/)
            @seperation_counter = 0
          end
        rescue Exception => e
          raise "An exception was raised while trying to tokenize '#{current_token_value} - #{e}'"
        end

        @token_index += current_token_value.size + @white_spaces - 1
        @white_spaces = 0

        return "statement", current_token_value
      end

      # Deal with special puppet class statement
      def is_klass?(j)
        while(j < @arguments.size && @arguments[j] == ' ')
          j += 1
        end

        if @arguments[j] =~ /=|<|>/
          return false
        else
          return true
        end
      end

      # Eat spaces while looking for the next comparison symbol
      def lookahead(index)
        index += 1
        while(index <= @arguments.size)
          @white_spaces += 1
          unless(@arguments[index] =~ /\s/)
            @seperation_counter +=1
            return index
          end
          index += 1
        end
        return nil
      end
    end
  end
end
