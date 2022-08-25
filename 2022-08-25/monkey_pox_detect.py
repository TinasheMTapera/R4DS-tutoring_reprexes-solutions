import os
import sys
import pandas as pd
from siuba import mutate, _


def read_in(path, target_sheet="sample_data"):
    try:

      if not os.path.exists(path):
        raise RuntimeError

      opened = pd.ExcelFile(path, engine="openpyxl")
      dfs = {
          sheet_name: opened.parse(sheet_name) for sheet_name in opened.sheet_names
      }
      output = dfs[target_sheet]

      expected_cols = ["date", "A2", "A9", "A10", "A11"]

      assert [x in output.columns for x in expected_cols]

      return output
    
    except RuntimeError as e:
      print("Could not open file \"{}\" Please check your paths".format(path), e)
      exit()

    except AssertionError as e:
      print("The required columns were not found")
      exit()

def monkey_pox_detect(input_path):

    df = read_in(input_path, target_sheet = "sample_data")

    target_regex = "monkey pox|pox|mpx|monkey|monkeypox"

    output_df = (df
      >> mutate(
        mp_detect1 = _.A2.str.contains("monkeypox status: monkeypox related"),
        mp_detect2 = _.A9.str.contains(target_regex),
        mp_detect3 = _.A10.str.contains(target_regex),
        mp_detect4 = _.A11.str.contains(target_regex)
        )
    )

    output_df["detected"] = output_df[["mp_detect1", "mp_detect2", "mp_detect3", "mp_detect4"]].any(axis=1)
    output_counts = output_df[["date", "detected"]].groupby("date").value_counts("detected").reset_index(name="counts")

    return output_counts[output_counts.detected ==  True]

def main():

    if not sys.argv or not len(sys.argv) == 2:
        raise ValueError("""   Error! Check Usage:

                    python monkey_pox_detect.py <PATH TO INPUT FILE>
                """)

    df = monkey_pox_detect(sys.argv[1])
    print(df)

if __name__ == "__main__":
    main()
