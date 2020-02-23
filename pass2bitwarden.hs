import Data.List
import System.IO
import System.Directory
import System.Environment
import System.Process
import Text.Printf


type FileName = String
type FileContents = String
data Creds = Creds
  { name :: String
  , password :: String
  , username :: String
  , note :: String
  } deriving Show


-- First FilePath is just the name of the file, second is the actual path
getFileTup :: FilePath -> IO [(FilePath, FilePath)]
getFileTup path = do
  contents <- getDirectoryContents path
  let nonHiddenContents = filter (not . isPrefixOf ".") contents
  let rootFiles = map (\x -> (takeWhile (/= '.') x, path <> x)) $ filter (elem '.') nonHiddenContents
  let dirs = map (\x -> path <> x <> "/") $ filter (notElem '.') nonHiddenContents
  dirFiles <- mapM getFileTup dirs
  pure $ rootFiles ++ concat dirFiles


parseFile :: FileName -> [FileContents] -> Creds
parseFile fName [x] = Creds
  { name = fName , password = x , username = "" , note = "" }
parseFile fName [x, y] = Creds
  { name = fName , password = x , username = y \\ "u: " , note = "" }
parseFile fName (x:y:zs) = Creds
  { name = fName , password = x , username = y \\ "u: " , note = concat zs }


csvHeader :: String
csvHeader = "folder,favorite,type,name,notes,fields,login_uri,login_username,login_password,login_totp"


-- Using string interpolation to create a template based on csvHeader
credsToCSV :: Creds -> String
credsToCSV creds =
  printf ",,login,%s,%s,,,%s,%s,," (name creds) (note creds) (username creds) (password creds)


main :: IO ()
main = do
  args <- getArgs
  let path = head args
  fileTups <- getFileTup path
  results <- mapM (\x -> readProcess "gpg" ["-d", snd x] []) fileTups
  let refinedResults = map (filter (\x -> head x /= '-') . lines) results
  let justFileNames = map fst fileTups
  let nameAndContents = zip justFileNames refinedResults
  let allCreds = map (uncurry parseFile) nameAndContents
  let csvCreds = map credsToCSV allCreds
  writeFile "temp.csv" $ unlines (csvHeader:csvCreds)
  print "All Done!"
