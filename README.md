# Pass2Bitwarden

This is to transfer passwords from [pass](https://www.passwordstore.org/) to bitwarden using CSV.

It's not the most polished program, but it gets the job done and is my first Haskell program that actually does something :D


## Running the program

1. Compile the program
2. Run the program and pass in the directory with your gpg keys with a leading slash at the end (i.e. `./p2b /home/me/.password-store/`)
3. That's it! It will produce a `temp.csv` file at the end which you can import!


## Lessons learned

IO in Haskell is _whack_, but interesting! I'm still getting used to the type, but I do like how it gets you thinking to separate your logic based on the context.

I originally tried to make just one function that would recursively navigate through the file system and decrypt accordingly, but I couldn't find a way to pull it off. I'm not a fan of the end result, but I am happy to have finally made something useful with Haskell.

Another thing that pained me while creating this was the nagging thought of using `Data.Text` instead of the native `String` type, but I figured since this is a small program it wouldn't hurt to ignore that. Still, it's really annoying to know the default type isn't recommended.

I also learned that `pure` is a way to return data within an `IO` context thanks to the r/Haskell community on Reddit! There were also some helpful comments further explaining working with IO.
