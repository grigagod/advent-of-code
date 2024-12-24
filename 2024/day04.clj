#!/usr/bin/env bb

(require '[clojure.string :as str])

(defn add [pos dir] (mapv + pos dir))
(defn mul [dir n] (mapv * dir [n, n]))

(defn rune-fn [matrix]
  (fn [pos]
    (let [[i j] pos]
      (cond
        (or (< i 0) (>= i (count matrix))) nil
        (or (< j 0) (>= j (count (first matrix)))) nil
        :else (nth (nth matrix i) j)))))

(defn is-match-fn [rune]
  (fn [want pos dir]
    (let [len (count want)
          got (apply str (map #(rune (add pos (mul dir %))) (range len)))]
      (= want got))))

(defn count-matches-fn [is-match]
  (let [dirs [[0 1] [0 -1] [1 0] [-1 0] [1 1] [-1 1] [1 -1] [-1 -1]]]
    (fn [want pos]
      (count (filter #(is-match want pos %) dirs)))))

(defn is-xmatch-fn [is-match]
  (fn [want pos]
    (and
     (or
      (is-match want (add pos [1 1]) [-1 -1])
      (is-match want (add pos [-1 -1]) [1 1]))
     (or
      (is-match want (add pos [1 -1]) [-1 1])
      (is-match want (add pos [-1 1]) [1 -1])))))

(defn matrix [input] (mapv #(vec %) (str/split-lines input)))

(let [m (matrix (slurp *in*))
      idxs (for [i (range (count m))
                 j (range (count (first m)))] [i j])
      is-match-fn (->> m rune-fn is-match-fn)
      count-matches (count-matches-fn is-match-fn)
      part1 (reduce + (map #(count-matches "XMAS" %) idxs))
      is-xmatch (is-xmatch-fn is-match-fn)
      part2 (count (filter #(is-xmatch "MAS" %) idxs))]
  (println part1)
  (println part2))
