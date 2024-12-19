#!/usr/bin/env bb

(require '[clojure.string :as str])

(defn matchMul [line] (map rest (re-seq #"mul\((\d+),(\d+)\)" line)))

(defn dropExcl [line] (str/replace line #"(?s)don't\(\)(.*?)do\(\)|$" ""))

(defn mul [args] (apply * (map Integer/parseInt args)))

(let [line (slurp *in*)
      all (reduce + (map mul (matchMul line)))
      excl (reduce + (map mul (matchMul (dropExcl line))))]
  (println all)
  (println excl))
