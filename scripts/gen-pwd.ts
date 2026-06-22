import * as bcrypt from "bcrypt";

bcrypt.hash("200521", 10).then((hash) => {
  console.log(hash);
  process.exit(0);
});
