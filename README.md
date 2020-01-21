# Xcode Project Renamer

**Swift script for renaming Xcode project**

It should be executed from inside root of Xcode project directory and called with two string parameters: 
**$OLD_PROJECT_NAME** & **$NEW_PROJECT_NAME**

Script goes through all the files and directories recursively, including Xcode project or workspace file and replaces all occurrences of **$OLD_PROJECT_NAME** string with **$NEW_PROJECT_NAME** string (both in each file's name and content).

## Usage

```bash
# download script
curl https://raw.githubusercontent.com/invokersdk/xcode-project-renamer/master/Sources/main.swift -o rename.swift

# Add Swift path to file
echo "#!/usr/bin/swift"|cat - rename.swift > /tmp/out && mv /tmp/out rename.swift

# make it executable
chmod +x rename.swift

# run script
./rename.swift "<OLD_PROJECT_NAME>" "<NEW_PROJECT_NAME>"

# remove script
rm rename.swift
```

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
