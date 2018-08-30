require 'parslet'
require 'parslet/convenience'
module Specko
  class Parser < Parslet::Parser
    root(:source)

    rule(:source) { (space? >> top_level >> newline >> properties.as(:properties) >> top_level_end >> any >> eof).as(:source) }
    rule(:top_level) { (str('class').repeat(1) >> space? >> top_level_name >> top_level_base.maybe).as(:top_level) }
    rule (:top_level_name) { match["A-Za-z"].repeat(0)}
    rule (:top_level_base) { space? >> match["<"] >> space? >> top_level_name  }
    rule(:properties) { (space? >>top_level_end.absent? >> property >> newline).repeat }
    rule(:property) {( method >> (space? >> params).maybe).as(:property) }
    rule(:method) { var_id.as(:method) }
    rule(:params) { param >> (match[","] >> newline.maybe >> space? >> param).repeat }
    rule(:param) { (symbol | key_value | constant | array).as(:argument)}
    rule(:key_value) { ((var_id | string) >> match[":"]).as(:key) >> space? >> value.as(:value) }
    rule(:value) { symbol.as(:symbol) | string.as(:string) | numeric.as(:numeric) | var_id.as(:id) | array.as(:array) | hash.as(:hash) }
    rule(:top_level_end) { str('end') }

    rule(:array) { str("[") >> space? >> a_element.maybe >>  (match[","] >> newline.maybe >> space? >> a_element).repeat >> space? >> str("]")}
    rule(:a_element) { str("]").absent? >> value  }
    rule(:hash) { str("{") >> space? >> key_value.maybe >> (match[","] >> newline.maybe >> space? >> key_value).repeat >> space? >> str("}")}
    rule(:numeric) { match["0-9"] >> match["0-9"].repeat }
    rule(:constant) { match["A-Z"] >> match["A-Za-z0-9"].repeat }
    rule(:string) { dstring | sstring }
    rule(:sstring) { match["'"] >> match('\w').repeat >> match["'"] }
    rule(:dstring) { match["\""] >> match('\w').repeat >> match["\""] }
    rule(:symbol) { match[":"] >> var_id }
    rule(:var_id) { match["a-z"] >> match["a-z0-9_\?\!"].repeat }
    rule(:space) { match('\s').repeat(1)}
    rule(:space?) { space.maybe }
    rule(:newline) { str("\n") }
   rule(:eof) { any.absent? }
  end
end
