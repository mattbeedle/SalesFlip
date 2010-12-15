var Base = new Class({

  initialize: function() {
    this.watchTitleTogglers();
    this.addRealTaskCalendar();
    this.hideActivityBodies();
    this.growTextAreas();
  },
  
  growTextAreas: function() {
    $$('textarea').each(function(t) {
      t.parent().insert("<div class='mirror'></div>")
      var mirror = t.parent().find('.mirror').first();
      mirror.update(text2html(t.value()))
      resizeMirror(t,mirror)
      t.on('keyup', function(event) {
        var nu = this.value();
        if (event.keyCode == 13) {var nu = this.value() + '\n'};
        mirror.update(text2html(nu));
        resizeMirror(this,mirror);
      }); 
    });
  },
    
  hideActivityBodies: function() {
    $$('.item-body').each(function(item) {
      item.addClass('hide');
    });
  },
  
  addRealTaskCalendar: function() {
    $$('.realdate').each(function(realdate) {
      var value_div = realdate.find('.value').first();
      var id        = value_div.get('object');
      var name      = value_div.get('name');
      var value     = value_div.html().trim();
      var abbr      = value_div.get('required')=='true' ? "<abbr>*</abbr>" : '';
      var input     = '<div class="string"><label for="' + id + '">' + abbr + value_div.get('title') + '</label><input id="' + id + '" type="text" name="' + name + '" value="' + value + '"/ autocomplete="off"></div>';
      var date_or_time = value_div.get('format')=='Date' ? "%Y-%m-%d" : "%Y-%m-%d %H:%M"; 
      
      realdate.find('span').first().remove();
      realdate.insert(input, 'top');
      new Calendar({ format: date_or_time}).assignTo(id);
    });
  },

  watchTitleTogglers: function() {

    //$$("div.toggle").each(function(div) { div.hide(); });

    $$("h3.toggler").each(function(h3) {

      h3.insert(new Element('span'), 'top');

      if ( h3.hasClass('open') ) {
        h3.select('span')[0].update('&#9660;');
        h3.next('.toggle').show();
      }
      else {
        h3.select('span')[0].update('&#9654;');
      };

      h3.onClick(function() {
        if ( this.hasClass('open') ) {
          this.select('span')[0].update('&#9654;');
        }
        else {
           this.select('span')[0].update('&#9660;');
        };
        this.next('.toggle').toggle('slide',{ duration:100 });
        this.toggleClass('open');
      });
    });
  }
});

$(document).on('ready', function() {
  new Base().initialize;
});

"#recent_activity span.toggler".on('click',function(event) {
    this.toggleClass('closed');
    this.parent().next().toggleClass('hide');
});

function text2html(string) {
  return string.replace(/&/g,'&amp;').replace(/  /g, '&nbsp;').replace(/<|>/g, '&gt;').replace(/\n\r?/g, '<br />');
};

function resizeMirror(elem, mirror) {
  elem.setHeight(mirror.getStyle('height').replace(/px/, '').toInt() + 40);
  mirror.setWidth(elem.getStyle('width').replace(/px/, '').toInt());
};