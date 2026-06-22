declare module "jszip" {
  export default class JSZip {
    file(path: string, data: any): JSZip;
    generateAsync(options: any): Promise<any>;
  }
}
