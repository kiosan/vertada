module BBCodeizer  
  class << self

    #:nodoc:
    Tags = {
      :start_code            => [ /\[code\]/i,                           '<pre>' ],
      :end_code              => [ /\[\/code\]/i,                         '</pre>' ],
      :start_quote           => [ /\[quote(?:=".*?")?\]/i,               nil ],
      :start_quote_with_cite => [ /\[quote="(.*?)"\]/i,                  '<blockquote><cite>\1</cite><br />' ],
      :start_quote_sans_cite => [ /\[quote\]/i,                          '<blockquote>' ],
      :end_quote             => [ /\[\/quote\]/i,                        '</blockquote>' ],
      :bold                  => [ /\[b\](.+?)\[\/b\]/im,                  '<strong>\1</strong>' ],
      :subp                  => [ /\[(su(b|p))\](.+?)\[\/\1\]/im,         '<\1>\3</\1>' ],
      :italic                => [ /\[i\](.+?)\[\/i\]/im,                  '<em>\1</em>' ],
      :underline             => [ /\[u\](.+?)\[\/u\]/im,                  '<u>\1</u>' ],
      :delete                => [ /\[del\](.+?)\[\/del\]/im,              '<del>\1</del>' ],
      :url_with_title        => [ /\[url=(.+?)\](.+?)\[\/url\]/im,        '<a href="\1">\2</a>' ],
      :url_sans_title        => [ /\[url\](.+?)\[\/url\]/im,              '<a href="\1">\1</a>' ],
      :image                 => [ /\[img\](.+?)\[\/img\]/im,              '<img src="\1" />' ],
      :size                  => [ /\[size=(\d\.?\d?\d?)\](.+?)\[\/size\]/im,  '<span style="font-size: \1em">\2</span>' ],
      :color                 => [ /\[color=([^;]+?)\](.+?)\[\/color\]/im, '<span style="color: \1">\2</span>'],
      :translate             => [ /\[t\](.+?)\[\/t\]/i,                  '\1']
    }
    
    #:nodoc:
    ClearTags = {
      :start_code            => [ /\[code\]/i,                           ' ' ],
      :end_code              => [ /\[\/code\]/i,                         ' ' ],
      :start_quote           => [ /\[quote(?:=".*?")?\]/i,               ' ' ],
      :start_quote_with_cite => [ /\[quote="(.*?)"\]/i,                  ' ' ],
      :start_quote_sans_cite => [ /\[quote\]/i,                          ' ' ],
      :end_quote             => [ /\[\/quote\]/i,                        ' ' ],
      :bold                  => [ /\[b\](.+?)\[\/b\]/i,                  '\1' ],
      :delete                => [ /\[del\](.+?)\[\/del\]/i,              '\1' ],
      :italic                => [ /\[i\](.+?)\[\/i\]/i,                  '\1' ],
      :underline             => [ /\[u\](.+?)\[\/u\]/i,                  '\1' ],
      :url_with_title        => [ /\[url=(.+?)\](.+?)\[\/url\]/i,        ' \1 \2 ' ],
      :url_sans_title        => [ /\[url\](.+?)\[\/url\]/i,              ' \1 ' ],
      :image                 => [ /\[img\](.+?)\[\/img\]/i,              ' \1 ' ],
      :size                  => [ /\[size=(\d\.?\d?\d?)\](.+?)\[\/size\]/i,' \2 ' ],
      :color                 => [ /\[color=([^;]+?)\](.+?)\[\/color\]/i, ' \2 '],
      :translate             => [ /\[t\](.+?)\[\/t\]/i,                  ' \1 '],
      :video                 => [ /\[video=(.+?)\](.+?)\[\/video\]/i,     '' ],
      :subp                  => [ /\[(su(b|p))\](.+?)\[\/\1\]/im,         '\3' ]
    }
    Smiles = [
      [["O:-)"], "aa.gif"], [[":-)", ":)"], "ab.gif"], [[":-(", ":("], "ac.gif"], [[";-)", ";)"], "ad.gif"], [[":-P", ":P"], "ae.gif"], [["8-)", "8)"], "af.gif"], [[":-D", ":D"], "ag.gif"],
      [[":-[", ":["], "ah.gif"], [["=-O"], "ai.gif"], [[":-*"], "aj.gif"], [[":'("], "ak.gif"], [[":-X"], "al.gif"], [["&gt;:o"], "am.gif"], [[":-|", ":|"], "an.gif"],
      [[":-/"], "ao.gif"], [["*JOKINGLY*"], "ap.gif"], [["]:-&gt;"], "aq.gif"], [["[:-}"], "ar.gif"], [["*KISSED*"], "as.gif"], [[":-!"], "at.gif"], [["*TIRED*"], "au.gif"],
      [["*STOP*"], "av.gif"], [["*KISSING*"], "aw.gif"], [["@}-&gt;--"], "ax.gif"], [["*THUMBS UP*"], "ay.gif"], [["*DRINK*"], "az.gif"], [["*IN LOVE*"], "ba.gif"], [["*HELP*"], "bc.gif"],
      [["\\m/"], "bd.gif"], [["%)"], "be.gif"], [["*OK*"], "bf.gif"], [["*WASSUP*"], "bg.gif"], [["*SORRY*"], "bh.gif"], [["*BRAVO*"], "bi.gif"], [["*LOL*", ":LOL:", ":lol:"], "bj.gif"],
      [["*PARDON*"], "bk.gif"], [["*NO*"], "bl.gif"], [["*CRAZY*"], "bm.gif"], [["*DONT_KNOW*"], "bn.gif"], [["*DANCE*"], "bo.gif"], [["*YAHOO*"], "bp.gif"], [["*FRIENDS*"], "bq.gif"]
    ]
    # Tags in this list are invoked. To deactivate a particular tag, call BBCodeizer.deactivate.
    # These names correspond to either names above or methods in this module.
    TagList = [ :bold, :italic, :underline, :delete, :url_with_title, :url_sans_title, :image, :size, :color,
                :code, :quote, :translate, :video, :subp]

    # Parses all bbcode in +text+ and returns a new HTML-formatted string.
    def bbcodeize(text)
      text = text.dup
      TagList.each do |tag|
        if Tags.has_key?(tag)
          apply_tag(text, tag)
        else
          self.send(tag, text)
        end
      end
      output = "#{text.strip}"

      # do some formatting
      output.gsub!(/\r\n/, "\n")       # remove CRLFs
      output.gsub!(/\n{3,}/, "\n\n")   # replace \n\n\n... with \n\n
      #output.gsub!(/\n\n/, '</p><p>')  # embed stuff in paragraphs
      output.gsub!(/\n/, '<br/>')      # nl2br
      apply_smiles(output, Smiles)
      output
    end

    # Configuration option to deactivate particular +tags+.
    def deactivate(*tags)
      tags.each { |t| TagList.delete(t) }
    end

    # Configuration option to change the replacement string used for a particular +tag+. The source
    # code should be referenced to determine what an appropriate replacement +string+ would be.
    def replace_using(tag, string)
      Tags[tag][1] = string
    end
    
    # Parses all bbcode in +text+ and returns a new HTML-formatted string.
    def bbclear(text)
      text = text.dup
      TagList.each do |tag|
        
        if tag==:quote
          if text.scan(ClearTags[:start_quote].first).size == text.scan(ClearTags[:end_quote].first).size
            apply_clear_tags(text, :start_quote_with_cite, :start_quote_sans_cite, :end_quote)
          end
        end
        if tag==:code
          if text.scan(ClearTags[:start_code].first).size == text.scan(ClearTags[:end_code].first).size
            apply_clear_tags(text, :start_code, :end_code)
          end
        end
        
        if ClearTags.has_key?(tag)

          apply_clear_tag(text, tag)
        end
      end
      output = "#{text.strip}"

      # do some formatting
      output.gsub!(/\r\n/, "\n")       # remove CRLFs
      output.gsub!(/\n{3,}/, "\n\n")   # replace \n\n\n... with \n\n
      output
    end
    
  private
    def apply_smiles(string, smiles)
       smiles.each do |smile|
          code, image = smile[0].collect {|code| Regexp.escape(code)}.join("|"), '<img class="smile" src="/images/smilies/%s" title="%s" />' % [smile[1], smile[0][0]]
          string.gsub!(Regexp.new(code), image)
        end
    end
    
    def code(string)
      # code tags must match, else don't do any replacing.
      if string.scan(Tags[:start_code].first).size == string.scan(Tags[:end_code].first).size
        apply_tags(string, :start_code, :end_code)
      end
    end
    
    def video(string)
      
      videos = {:youtube=>'<object width="425" height="355"><param name="movie" value="<url>"></param><param name="wmode" value="transparent"></param><embed src="<url>" type="application/x-shockwave-flash" wmode="transparent" width="425" height="355"></embed></object>'}
      res = string.scan(/\[video=(.+?)\](.+?)\[\/video\]/i)
      if res && res.length > 0
        # search
        rep_str = ''
        
        # youtube video
        # search for v parameter ang generate proper url for embeded video from video url
        if res[0][0] == 'youtube' 
          url = res[0][1].scan(/v=([-0-9A-Za-z_]+?)$/i)
        end
        if url
          rep_str = videos[:youtube].gsub('<url>', "http://www.youtube.com/v/#{url}")
        end
        string.gsub!(/\[video=(.+?)\](.+?)\[\/video\]/i, rep_str)
      end
    end
  
    def quote(string)
      # quotes must match, else don't do any replacing
      if string.scan(Tags[:start_quote].first).size == string.scan(Tags[:end_quote].first).size
        apply_tags(string, :start_quote_with_cite, :start_quote_sans_cite, :end_quote)
      end
    end

    def apply_tags(string, *tags)
      tags.each do |tag|
        if tag == :translate
          string.gsub!(Tags[tag][0]) do |s| 
            lkey = s.gsub(*Tags[tag])
            lkey.to_sym.t
          end
        else
          string.gsub!(*Tags[tag])
        end
      end
    end
    alias_method :apply_tag, :apply_tags
    
    def apply_clear_tags(string, *tags)
      tags.each do |tag|
          string.gsub!(*ClearTags[tag])
      end
    end
    alias_method :apply_clear_tag, :apply_clear_tags
  end
end