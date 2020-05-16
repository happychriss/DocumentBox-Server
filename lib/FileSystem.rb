module FileSystem

  def get_file_extension(type)
    case type
    when :jpg
      '.jpg'
    when :m_jpg
      '_m.jpg'
    when :s_jpg
      '_s.jpg'
    when :txt
      '.txt'
    when :gpg
      '.gpg'
    when :org
      '.org'
    when :pdf
      '.pdf'
    when :all
      '*.*'
    end
  end

  def file_name(type)
    #new_file_base_name=self.id.to_s + '_' + self.original_filename.chomp(File.extname(self.original_filename))
    self.id.to_s + get_file_extension(type)

  end

  def short_path(type)
    File.join('','docstore',self.file_name(type))
  end

  def path(type)
    File.join(self.docstore_path,self.file_name(type))
  end

  def file_exist?(type)
    File.exist?(self.path(type))
  end

  def docstore_path
    File.join(Rails.public_path,'docstore')
  end

  def save_file(data,type)
    f=File.open(self.path(type),"w");f.write(data);f.close
  end
end