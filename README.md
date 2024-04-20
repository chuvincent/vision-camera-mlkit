
# vision-camera-mlkit

Supports general bridge between Vision Camera and Google ML Kit

## Installation

```sh
npm install @chuvincent/vision-camera-mlkit
cd ios && pod install
```

Add the plugin to your `babel.config.js`:

```js
module.exports = {
   plugins: [['react-native-worklets-core/plugin']],
    // ...
```

> Note: You have to restart metro-bundler for changes in the `babel.config.js` file to take effect.

## Usage

```js
import {scanOCR} from '@chuvincent/vision-camera-mlkit';

// ...
const frameProcessor = useFrameProcessor((frame) => {
  'worklet';
  const scannedOcr = scanOCR(frame);
}, []);
```

# Publish to NPM
`npm run prepare`
 `npm run release`


## Data

`scanOCR(frame)` returns an `OCRFrame` with the following data shape. See the example for how to use this in your app.

 ``` jsx
  OCRFrame = {
    result: {
      text: string, // Raw result text
      blocks: Block[], // Each recognized element broken into blocks
    ;
};
```

The text object closely resembles the object documented in the MLKit documents.
<https://developers.google.com/ml-kit/vision/text-recognition#text_structure>

```
The Text Recognizer segments text into blocks, lines, and elements. Roughly speaking:

a Block is a contiguous set of text lines, such as a paragraph or column,

a Line is a contiguous set of words on the same axis, and

an Element is a contiguous set of alphanumeric characters ("word") on the same axis in most Latin languages, or a character in others
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
