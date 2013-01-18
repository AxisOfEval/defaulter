module Defaulter
  module HasDefault
    def has_default(model, *args)
      options = args.extract_options!

      has_many model.to_s.pluralize.to_sym, options do

        def default
          where(prime: true).limit(1).first
        end

        def default=(record)
          owner       = proxy_association.owner
          reflection  = proxy_association.reflection
          records     = load

          if records.include?(record)
            ActiveRecord::Base.transaction do
              # Marking existing record as default
              records.map { |r| r.update_attribute(:prime, false) if r.prime? }
              record.update_attribute(:prime, true)
            end
          else
            raise ActiveRecord::RecordNotFound, "Record not in collection"
          end
        end

        def << (models)
          owner       = proxy_association.owner
          reflection  = proxy_association.reflection
          model       = models.delete(models.select { |m| m.prime? }.last)

          if model.blank?
            self.concat(models)
          else
            models.each { |m| m.prime = false }
            ActiveRecord::Base.transaction do
              self.where(prime: true).each { |r| r.update_attribute(:prime, false) }
              self.concat(models + [model])
            end
          end
        end
      end
    end
  end
end