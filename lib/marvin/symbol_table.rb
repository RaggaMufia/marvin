require 'pry'
require 'log_buddy'

module Marvin

  # Contains scopes and their child variable types, keys, and values.
  class SymbolTable < Tree

    def initialize(config = nil)
      @config = config

      super(nil)
    end

    def from_ast(ast)
      @ast = ast.root

      @root = Marvin::Scope.new('<Scope>')

      traverse_ast(@ast, @root)
    end

    def traverse_ast(node, scope)
      node.children.each do |child|
        next unless child.is_production?

        production = child.content

        case production.name

        # If we reach a new block, let's create a new scope.
        # if production.name == 'Block'
        when 'Block'
          nested_scope = Marvin::Scope.new('<Scope>')

          # Add the nested scope to the current scope and set the current scope
          # to the nested scope.
          scope << nested_scope
          scope = nested_scope

        # If we reach a variable declaration, we're adding a new identifier to
        # the current scope.
        when 'VariableDeclaration'
          type = child.children.first.content.lexeme
          name = child.children.last.content.lexeme

          if scope.find_identifier(name, current_only: true)
            token = child.children.last.content

            @config.logger.warning("Redeclared identifier at #{token.lexeme} on line #{token.attributes[:line]} at character #{token.attributes[:char]}")
          end

          identifier = Marvin::Node.new(Marvin::Identifier.new(name, type))

          scope.add(identifier)

        # If we reach an assignment statement, we're going to check the type
        when 'Assignment'
          name = child.children.first.content.lexeme

          # Find the previous variable declaration.
          identifier = scope.find_identifier(name)

          # If we can't find an identifier, throw an error!
          return Marvin::Error::ScopeError.new(child.children.first.content) unless identifier

          declared_type = identifier.type
          given_type = child.children.last.resolve_type(scope)

          return Marvin::Error::TypeError.new(child.children.last, declared_type, given_type) if declared_type != given_type

          identifier = Marvin::Node.new(Marvin::Identifier.new(name, type))

          scope.add(identifier)
        end

        traverse_ast(child, scope)
      end
    end

    # Print out the tree.
    #
    # @return [nil]
    def print!
      puts "foo"

      @root.print_tree(@root.node_depth, nil, lambda { |node, prefix| puts "#{prefix} #{node.to_s}" })

      nil
    end
  end
end