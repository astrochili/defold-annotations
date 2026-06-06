return {
  {
    info = {
      namespace = 'mathx',
      language = 'Lua',
      brief = 'MathX API',
      description = 'Type fixture',
    },
    elements = {
      {
        type = 'ALIAS',
        name = 'mathx.LocalAlias',
        alias = 'string|number',
      },
      {
        type = 'CLASS',
        name = 'mathx.LocalClass',
        fields = {
          id = 'hash',
        },
      },
      {
        type = 'FUNCTION',
        name = 'mathx.mix',
        description = 'Mix values',
        parameters = {
          { name = 'a', doc = 'First value', types = { 'number|vector3' }, is_optional = 'False' },
          { name = 'b', doc = 'Second value', types = { 'number|vector3' }, is_optional = 'False' },
          { name = 'weight', doc = 'Weight', types = { 'number' }, is_optional = 'False' },
        },
        returnvalues = {
          { name = 'result', doc = 'Mixed value', types = { 'number|vector3' } },
        },
      },
      {
        type = 'FUNCTION',
        name = 'mathx.consume',
        description = 'Consume rich types',
        parameters = {
          { name = 'rotation', doc = 'Quaternion', types = { 'quat' }, is_optional = 'False' },
          { name = 'data', doc = 'Inline table', types = { '{ id:hash }' }, is_optional = 'False' },
          { name = 'callback', doc = 'Callback', types = { 'function(value:number):string' }, is_optional = 'False' },
          { name = 'either', doc = 'Alias union', types = { 'mathx.LocalAlias' }, is_optional = 'False' },
          { name = 'items', doc = 'Array items', types = { '[hash]' }, is_optional = 'False' },
        },
        returnvalues = {
          { name = 'record', doc = 'Generated class', types = { 'mathx.LocalClass' } },
          { name = 'mystery', doc = 'Unknown type', types = { 'mystery_type' } },
        },
      },
    },
  },
}
