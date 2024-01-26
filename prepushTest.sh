#!/usr/bin/env bash

# Тестируем изменения относительно remote branch.
# Если создаем новую ветку - тестируем изменения относительно последнего коммита, которого нет в origin

read local_ref local_sha remote_ref remote_sha <<< $HUSKY_GIT_STDIN
read remote repo_url <<< $HUSKY_GIT_PARAMS

z40=0000000000000000000000000000000000000000

if [[ -n "${local_ref}" ]]; then
    if [[ "$local_sha" = $z40 ]];
    then
        # Handle delete
        exit 0
    else
        if [[ "$remote_sha" = $z40 ]];
        then
            # новый бранч, берем последний коммит которого нет в origin
            last_local_commit=`git rev-list HEAD --not --remotes=$remote | tail -1`
            # и нам будет нужен соответственно его предок, он как раз будет коммитом расхождения:
            sha_base=`git rev-parse "$last_local_commit"~1`
        else
            # ветка уже есть, проверям только то, что изменилось относительно запушенной ветки
            sha_base="$remote_sha"
        fi

        if [[ -n "${sha_base}" ]]; then
            jest --changedSince $sha_base || exit 1
        fi
    fi
fi
