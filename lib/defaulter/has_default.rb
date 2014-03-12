module Defaulter
  module HasDefault
    def has_default(model, *args)
      resource      = model.to_sym
      options       = args.extract_options!
      resources     = resource.to_s.pluralize.to_sym
      column_name   = options.delete(:default_column) || :prime
      column_setter = "#{column_name}=".to_sym

      # Unused
      # method        = "default_#{resource}_column".to_sym
      # class_variable_set("@@#{method}".to_sym, column_name.freeze)
      # define_singleton_method(method) { class_variable_get("@@#{method}".to_sym) }

      def load_method
        @@load_method ||= (Gem::Version.new('4.0.0') >=
          Gem::Version.new(Rails.version)) ? :all : :load
      end

      has_many resources, options do

        define_method(:default) { where(column_name => true).limit(1)[0] }

        define_method(:default=) do |record|
          records = self.send(load_method)

          if records.include?(record)
            ActiveRecord::Base.transaction do
              # Marking existing record as default
              records.map { |r| r.update_attribute(column_name, false) if
                r.send(column_name) }
              record.update_attribute(column_name, true)
            end
          else
            raise ActiveRecord::RecordNotFound, "Record not in collection"
          end
        end

        define_method(:<<) do |records|
          records_on_db = self.send(load_method)
          none_on_db    = records_on_db.empty?
          default_on_db = records_on_db.select { |r| r.send(column_name) }

          case records.class.name
          when 'Array'
            # Find out if any default records have been given
            default_records = records.select do |r|
              r.send(column_name)
            end

            # Mark the first record as default iff:
            # 1. None exist on DB
            # 2. Given array of records is NOT empty
            # 3. Given records have no default record marked
            records[0].send(column_setter, true) if
              none_on_db &&
              !records.empty? &&
              default_records.empty?

            # Candidate default record if none given or none on db
            default_record = records.delete(default_records[-1])

            ActiveRecord::Base.transaction do
              if default_record.blank?
                self.concat(records) unless records.blank?
              else
                records.each { |r| r.send(column_setter, false) }

                default_on_db.each do |r|
                  r.update_attribute(column_name, false)
                end

                self.concat(records + [default_record])
              end
            end
          else
            unless records.blank?
              records.send(column_setter, true) if default_on_db.blank?

              ActiveRecord::Base.transaction do
                if records.send(column_name)
                  default_on_db.map do |r|
                    r.update_attribute(column_name, false)
                  end
                end

                self.concat(records)
              end
            end
          end
        end
      end
    end
  end
end
