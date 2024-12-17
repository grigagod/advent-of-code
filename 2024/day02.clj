#!/usr/bin/env bb

(require '[clojure.string :as str])

(defn isSafe? [lvl]
  (let [diffs (map - (rest lvl) lvl)]
    (and
     (or (every? pos? diffs) (every? neg? diffs))
     (every? #(<= 1 (abs %) 3) diffs))))

(defn sublvls [line]
  (map #(vec (concat (take % line) (drop (inc %) line))) (range (count line))))

(println
 (count
  (filter (fn [lvl] (some isSafe? (cons lvl (sublvls lvl))))
          (map (fn [line] (map #(Integer/parseInt %) (str/split line #"\s+")))
               (line-seq (java.io.BufferedReader. *in*))))))
