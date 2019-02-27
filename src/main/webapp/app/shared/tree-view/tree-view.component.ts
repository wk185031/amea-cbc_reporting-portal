import { Component, Input, Output, EventEmitter } from '@angular/core';
import { TreeModule, TreeNode} from 'angular-tree-component';

@Component({
    selector: 'jhi-tree-view',
    templateUrl: './tree-view.component.html'
})
export class JhiTreeViewComponent {
    @Input() nodes: TreeModule;
    @Input() showCheckedBox: boolean;
    @Output() notify: EventEmitter<number> = new EventEmitter<number>();
    constructor(
    ) {
    }

    check(node, $event) {
        node.data.indeterminate = false;
        this.updateChildNodesCheckBox(node, $event.target.checked);
        this.updateParentNodesCheckBox(node.parent);
    }

    updateChildNodesCheckBox(node: TreeNode, checked) {
        node.data.checked = checked;
        node.data.indeterminate = false;
        if (node.children) {
            node.children.forEach((child) => this.updateChildNodesCheckBox(child, checked));
        }
    }

    updateParentNodesCheckBox(node) {
        if (node && node.level > 0 && node.children) {
            let allChildChecked = true;
            let noChildChecked = true;
            let containIndeterminate = false;

            for (const child of node.children) {
                if (!child.data.checked) {
                    allChildChecked = false;
                }
                if (child.data.checked) {
                    noChildChecked = false;
                }
                if (child.data.indeterminate) {
                    containIndeterminate = true;
                }
            }

            if (allChildChecked) {
                node.data.checked = true;
                node.data.indeterminate = (containIndeterminate) ? true : false;
            } else if (noChildChecked) {
                node.data.checked = false;
                node.data.indeterminate = false;
            } else {
                node.data.checked = true;
                node.data.indeterminate = true;
            }
            this.updateParentNodesCheckBox(node.parent);
        }
    }

    onEvent(evt) {
        this.notify.emit(evt.node.data.id);
    }
}
