Mongoid.database.eval(
  <<-JAVASCRIPT
  db.system.js.save( { _id : 'contains', value : function( array, value ) {
    a = false;
    for(i = 0; i < array.length; i++) {
      if(array[i] == value) {
        a = true;
      }
    }
    return a;
  } } );
  JAVASCRIPT
)
