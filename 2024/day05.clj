#!/usr/bin/env bb

(require '[clojure.string :as str])
(require '[clojure.set :as set])

(defn mapRules [rules]
  (reduce (fn [m [k v]]
            (assoc m k (set (mapcat rest v))))
          {}
          (group-by first rules)))

(defn subpages [page] (map #(drop % page) (range (count page))))

(defn is-correct-fn [rules]
  (fn [page]
    (every? empty?
            (map #(set/intersection (rules (first %)) (set (rest %)))
                 (subpages (reverse page))))))

(defn take-middle [page] (Integer/parseInt (nth page (quot (count page) 2))))

(let [parts (->> (slurp *in*) (#(str/split % #"\n\s*\n")) (map str/split-lines))
      rules (->> (first parts) (map #(str/split % #"\|")) mapRules)
      pages (->> (second parts) (map #(str/split % #"\,")))
      is-correct (is-correct-fn rules)]

  (->> (filter is-correct pages)
       (map take-middle)
       (reduce +)
       println)

  (defn fix-page [rules page] (sort (fn [a b] (contains? (rules a) b)) page))
  (->> (filter #(not (is-correct %)) pages)
       (map #(fix-page rules %))
       (map take-middle)
       (reduce +)
       println))
