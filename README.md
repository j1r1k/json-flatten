# json-flatten

Simplify structure of a JSON while complicating key names

## Examples

##### JSON document used in later examples

```
# cat example.json
```
```javascript
{
  "a": {
    "b": { "c": 1 },
    "a": [
      { "x": 2 },
      { "y": { "z": 3 } }
    ]
  }
}
```

##### Basic usage

This will flatten all objects, nested arrays will not inherit prefix from their parent key.

```
# json-flatten <example.json | jq .
```
```javascript
{
  "a.b.c": 1,
  "a.a": [
    {
      "x": 2
    },
    {
      "y.z": 3
    }
  ]
}
```

##### With `--arrays` 

Arrays will inherit prefix from their parent key.

```
# json-flatten --arrays <example.json | jq .
```
```javascript
{
  "a.b.c": 1,
  "a.a": [
    {
      "a.a.x": 2
    },
    {
      "a.a.y.z": 3
    }
  ]
}
```

##### With `--prefix "prefix"`

Keys in top level object will be prefixed with given string.

```
# json-flatten --prefix "prefix" <example.json | jq .
```
```javascript
{
  "prefix.a.a": [
    {
      "x": 2
    },
    {
      "y.z": 3
    }
  ],
  "prefix.a.b.c": 1
}

```

##### With both `--arrays` and `--prefix "prefix"`

Keys in objects in arrays will get prefixed with their parent key (including prefix given as parameter).

```
# json-flatten --arrays --prefix "prefix" <example.json | jq .
```
```javascript
{
  "prefix.a.a": [
    {
      "prefix.a.a.x": 2
    },
    {
      "prefix.a.a.y.z": 3
    }
  ],
  "prefix.a.b.c": 1
}
```

##### With `--separator "_-_"`

Will separate keys with separator given as parameter.

```
# json-flatten --separator "_-_" <example.json | jq .
```
```javascript
{
  "a_-_a": [
    {
      "x": 2
    },
    {
      "y_-_z": 3
    }
  ],
  "a_-_b_-_c": 1
}
```



## Notes

##### Order of keys is not stable and might change

##### Conflicting names are not handled (only last occurrence will be kept)

```
cat example.json
```
```javascript
{
  "a": {
    "b": { "c": 1 },
    "b": { "c": 2 },
    "b": { "c": 3 }
  }
}
```

```
# json-flatten < example.json | jq .
```
```javascript
{
  "a.b.c": 3
}
```

## Installation

Run either `cabal install` or `stack install`. This produces executable `json-flatten`

## Discalmer

Any feedback is very welcomed.
