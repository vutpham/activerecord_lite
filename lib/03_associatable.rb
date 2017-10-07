require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {class_name: name.to_s.camelcase, primary_key: :id,
                foreign_key: "#{name}_id".to_sym}
    overridden = defaults.merge(options)

    @class_name = overridden[:class_name]
    @primary_key = overridden[:primary_key]
    @foreign_key = overridden[:foreign_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end

end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    opts = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign = opts.send(:foreign_key)
      primary = opts.send(:primary_key)

      opts.model_class.where(primary => self.send(foreign)).first
    end
  end

  def has_many(name, options = {})
    opts = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      foreign = opts.send(:foreign_key)
      primary = opts.send(:primary_key)

      opts.model_class.where(foreign => self.send(primary))
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
