// patch AppRun file in AppImage, so that it support Wayland

import { execSync } from "child_process";
import path from "path";

const scriptPath = path.resolve(__dirname, "../../scripts/patch-apprun.sh");

export async function patchAppImage(appFileName: string) {
  execSync(`bash ${scriptPath} ${appFileName}`);
}
