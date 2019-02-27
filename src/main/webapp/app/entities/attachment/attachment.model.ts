import { BaseEntity } from './../../shared';
import { AttachmentGroup } from '../attachment-group';

export class Attachment implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public type?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public attachmentGroup?: AttachmentGroup,
        public blobFile?: any,
        public imageSource?: any,
        public removeFlag?: boolean,
        public hiddenFlag?: boolean
    ) {
        this.removeFlag = false;
        this.hiddenFlag = false;
    }
}
