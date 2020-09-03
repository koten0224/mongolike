class Setting < ApplicationRecord
  include Settings::Common
  belongs_to :owner, polymorphic: true
  before_update :kill_children, if: ->{:cls.in?(changes) && cls_was.present?}

  def value
    return if cls.nil?
    return class_trans_mapping[cls].call if cls.in?(class_trans_mapping)
    klass = cls.constantize
    if ActiveRecord::Base.in? klass.ancestors
      klass.find self['value']
    else
      nil
    end
  end

  def value=(val)
    self['cls'] = val.class
    if val.is_a? ApplicationRecord
      val = val.id
    elsif val.is_a? Hash
      val.each do |k,v|
        setting[k]=v
      end
      val = nil
    elsif val.is_a? Array
      val = nil
    end
    self['value'] = val
  end

  private

  def class_trans_mapping
    @class_trans_mapping ||= {
      'Integer' => ->{self['value'].to_i},
      'String' => ->{self['value']},
      'Hash' => ->{self.setting},
      'Array' => ->{[]},
      'TrueClass' => ->{true},
      'FalseClass' => ->{false},
      'NilClass' => ->{nil}
    }
  end
end
