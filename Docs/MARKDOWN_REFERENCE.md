# Markdown Reference

### Headers

```markdown
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

### Text

```markdown
_italic_ or *italic*

**bold** or __bold__

~~strikethrough~~
```

### Blockquotes

```markdown
> This is a blockquote
```

### Horizontal Rule

```markdown
---

***

___
```

### Lists

```markdown
1. Ordered list
2. ...

- Unordered list
* With *
+ With +
```

### Links

```markdown
[Inine](https://a.com)

[Inline with title](https://a.com "A title")

[Reference][1]

[Link to file](./Docs/SETUP.md)

[1]: https://a.com
```

### Images

```markdown
![Inline](https://a.com/logo.png)

![Reference][logo]

[logo]: https://a.com/logo.png
```

### Code

````markdown
`Inline code`

```javascript
const x = 5;
const plusTwo = a => a + 2;
```
````

### Tables

```markdown
| Column 1      | Column 2      |  Column 3 |
| ------------- |:-------------:| ---------:|
| Col 3 is      | right-aligned | $1600     |
| Col 2 is      | centered      |   $12     |
| Tables        | are neat      |    $1     |
```

### HTML

```markdown
<a href="https://a.com">Link</a>
<img src="https://a.com/logo.png" width="100">
```
