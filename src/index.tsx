/* eslint-disable no-undef */
import { VisionCameraProxy, Frame } from 'react-native-vision-camera';

type BoundingFrame = {
  x: number;
  y: number;
  width: number;
  height: number;
  boundingCenterX: number;
  boundingCenterY: number;
};

type BoundingBox = {
  top: number;
  right: number;
  bottom: number;
  left: number;
};

type Point = { x: number; y: number };

type Symbol = {
  text: string;
  cornerPoints?: Point[];
  frame?: BoundingFrame;
  boundingBox?: BoundingBox;
};

type TextElement = {
  text: string;
  frame?: BoundingFrame;
  boundingBox?: BoundingBox;
  cornerPoints?: Point[];
  symbols?: Symbol[];
};

type TextLine = {
  text: string;
  elements: TextElement[];
  frame?: BoundingFrame;
  boundingBox?: BoundingBox;
  recognizedLanguages: string[];
  cornerPoints?: Point[];
};

type TextBlock = {
  text: string;
  lines: TextLine[];
  frame?: BoundingFrame;
  boundingBox?: BoundingBox;
  recognizedLanguages: string[];
  cornerPoints?: Point[];
};

type Text = {
  text: string;
  blocks: TextBlock[];
};

export type OCRFrame = {
  result: Text;
};

/**
 * Scans OCR.
 */
const plugin = VisionCameraProxy.initFrameProcessorPlugin('scanOCR');

export function scanOCR(frame: Frame): OCRFrame {
  'worklet';
  if (plugin == null) {
    throw new Error(
      'Failed to load Frame Processor Plugin "scanOCR"! Please check your dependencies and make sure that the plugin is linked correctly.'
    );
  }
  return plugin.call(frame) as any;
}


/**
 * Image Labeler
 */
const plugin2 = VisionCameraProxy.initFrameProcessorPlugin('scanOCR');

interface ImageLabel {
  /**
   * A label describing the image, in english.
   */
  label: string;
  /**
   * A floating point number from 0 to 1, describing the confidence (percentage).
   */
  confidence: number;
}

/**
 * Returns an array of matching `ImageLabel`s for the given frame.
 *
 * This algorithm executes within **~60ms**, so a frameRate of **16 FPS** perfectly allows the algorithm to run without dropping a frame. Anything higher might make video recording stutter, but works too.
 */
export function labelImage(frame: Frame): ImageLabel[] {
  'worklet';
  // @ts-expect-error Frame Processors are not typed.
  return __labelImage(frame);
}
