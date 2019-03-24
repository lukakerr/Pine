#  Plugins

Creating a preview plugin is easy. Follow the steps below to get started:

1. Open the Pine preferences window and select the 'Preview' tab
2. Click 'Reveal Plugins'

At this point a directory named `Plugins` will appear. This is where all the active plugins are stored. 

Plugins are written in JavaScript and loaded directly into the preview window.
This means you can do almost an manipulation you want to the elements displayed in the preview.

### An Example

Lets write a quick plugin to make all header elements appear green in color.

1. Create a file named `headers.js` and save it in the `Plugins` directory mentioned above

2. Inside this file, copy and paste the following JavaScript:

  ```javascript
  var headers = document.querySelectorAll("h1, h2, h3, h4, h5, h6");
  
  for (var i = 0; i < headers.length; i++) {
    headers[i].style.color = "green";
  }
  ```

What this does it find every `<h..>` element and set its color to green.

3. Close and re-open Pine, and type `# A Green Heading!` into the editor, you'll now notice
  the heading is shown as green in the preview.
